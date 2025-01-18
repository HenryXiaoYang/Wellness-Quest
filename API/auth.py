from datetime import datetime, timedelta
from typing import Annotated
from fastapi import Depends, HTTPException, status, APIRouter
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from pydantic import BaseModel, Field
from sqlmodel import Session, select

from .database import User, api_database, Gender
from .config import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter()

# Models
class Token(BaseModel):
    access_token: str
    token_type: str

class UserCreate(BaseModel):
    username: str
    password: str
    full_name: str | None = None
    age: int | None = Field(default=None, ge=13)
    gender: Gender | None = None

class UserResponse(BaseModel):
    id: int
    username: str
    full_name: str | None = None
    age: int | None = None
    gender: Gender | None = None
    nutrition_prefrence: list[str] | None = None
    exercise_prefrence: list[str] | None = None
    rest_prefrence: list[str] | None = None
    completed_quests: int  
    level: int
    points: int

# Auth utilities
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")
SessionDep = Annotated[Session, Depends(api_database.get_session)]

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    session: SessionDep
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = session.exec(select(User).where(User.username == username)).first()
    if user is None:
        raise credentials_exception
    return user

@router.post("/login", response_model=Token)
async def login(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    session: SessionDep
):
    user = await api_database.authenticate_user(session, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/register", response_model=UserResponse)
async def register(user: UserCreate, session: SessionDep):
    # Validate username
    existing_user = session.exec(select(User).where(User.username == user.username)).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )
    
    # Validate age
    if user.age is not None and user.age < 13:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User must be at least 13 years old"
        )
    
    # Create user with empty preferences
    db_user = User(
        username=user.username,
        hashed_password=api_database.get_password_hash(user.password),
        full_name=user.full_name,
        age=user.age,
        gender=user.gender,
        nutrition_prefrence=[],
        exercise_prefrence=[],
        rest_prefrence=[],
        completed_quests=0,
        level=1,
        points=0
    )
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    return db_user

class ProfileUpdate(BaseModel):
    full_name: str | None = None
    age: int | None = Field(default=None)
    gender: Gender | None = None
    nutrition_prefrence: list[str] | None = None
    exercise_prefrence: list[str] | None = None
    rest_prefrence: list[str] | None = None

@router.post("/profile", response_model=UserResponse)
async def update_profile(
    profile: ProfileUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    session: SessionDep
):
    # validate the age
    if profile.age is not None and profile.age < 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid age"
        )

    if profile.age is not None:
        current_user.age = profile.age
    if profile.gender is not None:
        current_user.gender = profile.gender
    if profile.full_name is not None:
        current_user.full_name = profile.full_name
    
    if profile.nutrition_prefrence is not None:
        current_user.nutrition_prefrence = profile.nutrition_prefrence
    if profile.exercise_prefrence is not None:
        current_user.exercise_prefrence = profile.exercise_prefrence
    if profile.rest_prefrence is not None:
        current_user.rest_prefrence = profile.rest_prefrence
    
    session.add(current_user)
    session.commit()
    session.refresh(current_user)
    return current_user 