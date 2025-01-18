from typing import Optional
from sqlmodel import Field, Session, SQLModel, create_engine, select, JSON
from passlib.context import CryptContext
from datetime import datetime
from enum import Enum

class Gender(str, Enum):
    MALE = "male"
    FEMALE = "female"
    NON_BINARY = "non-binary"

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(index=True, unique=True)
    hashed_password: str
    full_name: Optional[str] = None
    age: Optional[int] = Field(default=None)
    gender: Optional[Gender] = None
    nutrition_prefrence: Optional[list[str]] = Field(default=None, sa_type=JSON)
    exercise_prefrence: Optional[list[str]] = Field(default=None, sa_type=JSON)
    rest_prefrence: Optional[list[str]] = Field(default=None, sa_type=JSON)
    completed_quests: int = Field(default=0)
    level: int = Field(default=1)
    points: int = Field(default=0)

class QuestType(str, Enum):
    NUTRITION = "nutrition"
    EXERCISE = "exercise"
    REST = "rest"

class Quest(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    quest_id: str = Field(index=True, unique=True)
    user_id: int = Field(foreign_key="user.id")
    type: QuestType
    name: str
    description: str
    details: dict = Field(sa_type=JSON)
    completed: bool = Field(default=False)
    accepted: bool = Field(default=False)
    created_at: datetime = Field(default_factory=datetime.utcnow)

class APIDatabase:
    def __init__(self):
        sqlite_file_name = "database.db"
        sqlite_url = f"sqlite:///{sqlite_file_name}"
        connect_args = {"check_same_thread": False}
        self.engine = create_engine(sqlite_url, connect_args=connect_args)
        SQLModel.metadata.create_all(self.engine)
        self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

    def get_session(self):
        with Session(self.engine) as session:
            yield session

    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        return self.pwd_context.verify(plain_password, hashed_password)

    def get_password_hash(self, password: str) -> str:
        return self.pwd_context.hash(password)

    async def authenticate_user(self, session: Session, username: str, password: str):
        user = session.exec(select(User).where(User.username == username)).first()
        if not user:
            return False
        if not self.verify_password(password, user.hashed_password):
            return False
        return user


api_database = APIDatabase()


