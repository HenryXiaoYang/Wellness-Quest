from typing import Annotated, Optional, List
from fastapi import FastAPI, Depends, HTTPException
from sqlmodel import Session, select

from .database import Quest, QuestType, User, api_database
from .auth import router as auth_router, get_current_user
from .quest_generation import (
    generate_nutrition_quest,
    generate_exercise_quest,
    generate_rest_quest
)

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Wellness Quest Backend",
    summary="Authors: HenryXiaoYang Henry Yang https://github.com/HenryXiaoYang, YifanzzzzZ Sunny Zhu https://github.com/YifanzzzzZ",
    description="Backend for Wellness Quest APP  https://github.com/HenryXiaoYang/Wellness-Quest",
    version="1.0.0",
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# add routers
app.include_router(auth_router, prefix="/auth", tags=["Authentication"])

async def manage_quests(
    session: Session,
    user_id: int,
    quest_type: QuestType,
) -> List[Quest]:
    """Manage existing quests and return accepted quests"""
    # get the existing quests
    existing_quests = session.exec(
        select(Quest).where(
            Quest.user_id == user_id,
            Quest.type == quest_type
        )
    ).all()
    
    # delete unwanted quests
    for quest in existing_quests:
        if not quest.accepted:
            session.delete(quest)
    
    session.commit()
    
    # remaining accepted quests
    return [q for q in existing_quests if q.accepted]

@app.get("/quests/{quest_type}/get", tags=["Quests"])
async def get_quests(
    quest_type: QuestType,
    current_user: Annotated[User, Depends(get_current_user)],
    session: Annotated[Session, Depends(api_database.get_session)],
):
    """Get or generate quests for the user"""
    accepted_quests = await manage_quests(session, current_user.id, quest_type)

    new_count = 3 - len(accepted_quests)
    if new_count <= 0:
        return {"message": "Already have maximum accepted quests", "quests": accepted_quests}

    # keep only last 10 prefrence
    if quest_type == QuestType.NUTRITION:
        current_user.nutrition_prefrence = current_user.nutrition_prefrence[:10]
        preferences = current_user.nutrition_prefrence
        generate_func = generate_nutrition_quest
    elif quest_type == QuestType.EXERCISE:
        current_user.exercise_prefrence = current_user.exercise_prefrence[:10]
        preferences = current_user.exercise_prefrence
        generate_func = generate_exercise_quest
    else: # rest quest
        current_user.rest_prefrence = current_user.rest_prefrence[:10]
        preferences = current_user.rest_prefrence
        generate_func = generate_rest_quest

    # generate new quests
    response = await generate_func(
        count=new_count,
        user_age=current_user.age,
        user_gender=current_user.gender.value if current_user.gender else "unspecified",
        preferences=preferences
    )
    
    # save new quests to database
    new_quests = []
    for quest in response.Quests:
        quest_details = {}
        if quest_type == QuestType.NUTRITION:
            quest_details = {"calories": quest.calories, "recipe": quest.recipe, "nutrition": quest.nutrition}
        elif quest_type == QuestType.EXERCISE:
            quest_details = {
                "calories": quest.calories,
                "instruction": quest.instruction,
                "duration": quest.duration
            }
        else:  # rest quest
            quest_details = {"duration": quest.duration, "when": quest.when}

        quest = Quest(
            quest_id=quest.quest_id,
            user_id=current_user.id,
            type=quest_type,
            name=quest.name,
            description=quest.description,
            details=quest_details
        )
        session.add(quest)
        new_quests.append(quest)
    
    session.commit()

    for quest in new_quests:
        session.refresh(quest)
    for quest in accepted_quests:
        session.refresh(quest)
        
    return {"quests": accepted_quests+new_quests}

@app.get("/quests/{quest_id}/complete", tags=["Quests"])
async def complete_quest(
    quest_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    session: Annotated[Session, Depends(api_database.get_session)],
):
    """Complete a quest"""
    quest = session.exec(
        select(Quest).where(
            Quest.quest_id == quest_id,
            Quest.user_id == current_user.id
        )
    ).first()
    
    if not quest:
        raise HTTPException(status_code=404, detail="Quest not found")
    
    # update user points
    current_user.completed_quests += 1
    current_user.points += 10  # Add 10 points for completing a quest
    
    # level up by every 5 completed quests
    if current_user.completed_quests % 5 == 0:
        current_user.level += 1
    
    # store quest details for response
    quest_response = {
        "id": quest.id,
        "quest_id": quest.quest_id,
        "name": quest.name,
        "user_id": quest.user_id,
        "details": quest.details,
        "accepted": quest.accepted,
        "type": quest.type,
        "description": quest.description,
        "completed": True,
        "created_at": quest.created_at
    }
    
    # delete the quest
    session.delete(quest)
    session.add(current_user)
    session.commit()
    
    return {
        "quest": quest_response,
        "user_stats": {
            "completed_quests": current_user.completed_quests,
            "level": current_user.level,
            "points": current_user.points
        }
    }

@app.get("/quests/{quest_id}", tags=["Quests"])
async def get_quest_details(
    quest_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    session: Annotated[Session, Depends(api_database.get_session)]
):
    """Get detailed information about a quest"""
    quest = session.exec(
        select(Quest).where(
            Quest.quest_id == quest_id,
            Quest.user_id == current_user.id
        )
    ).first()
    
    if not quest:
        raise HTTPException(status_code=404, detail="Quest not found")
    
    return quest

@app.get("/quests/{quest_id}/delete", tags=["Quests"])
async def delete_quest(
    quest_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    session: Annotated[Session, Depends(api_database.get_session)],
):
    """Delete a quest"""
    quest = session.exec(
        select(Quest).where(
            Quest.quest_id == quest_id,
            Quest.user_id == current_user.id
        )
    ).first()
    
    if not quest:
        raise HTTPException(status_code=404, detail="Quest not found")
    
    # deduct points if the quest was accepted, this is a penalty
    if quest.accepted:
        current_user.points = max(0, current_user.points - 5)  # Prevent negative points
        session.add(current_user)
    
    session.delete(quest)
    session.commit()
    
    return {
        "message": "Quest deleted successfully",
        "points_deducted": 5 if quest.accepted else 0,
        "current_points": current_user.points
    }

@app.get("/users/profile", tags=["Users"])
async def get_user_profile(
    current_user: Annotated[User, Depends(get_current_user)]
):
    """Get current user's profile information"""
    return {
        "id": current_user.id,
        "username": current_user.username,
        "full_name": current_user.full_name,
        "age": current_user.age,
        "gender": current_user.gender,
        "nutrition_prefrence": current_user.nutrition_prefrence,
        "exercise_prefrence": current_user.exercise_prefrence,
        "rest_prefrence": current_user.rest_prefrence,
        "completed_quests": current_user.completed_quests,
        "level": current_user.level,
        "points": current_user.points
    }

@app.get("/quests/{quest_id}/accept", tags=["Quests"])
async def accept_quest(
    quest_id: str,
    current_user: Annotated[User, Depends(get_current_user)],
    session: Annotated[Session, Depends(api_database.get_session)]
):
    """Mark a quest as accepted"""
    quest = session.exec(
        select(Quest).where(
            Quest.quest_id == quest_id,
            Quest.user_id == current_user.id
        )
    ).first()
    
    if not quest:
        raise HTTPException(status_code=404, detail="Quest not found")
    
    # check if user already has 3 accepted quests of this type
    accepted_count = session.exec(
        select(Quest).where(
            Quest.user_id == current_user.id,
            Quest.type == quest.type,
            Quest.accepted == True
        )
    ).all()
    
    if len(accepted_count) >= 3:
        raise HTTPException(
            status_code=400,
            detail=f"Already have maximum accepted {quest.type.value} quests"
        )
    
    quest.accepted = True
    session.add(quest)
    session.commit()
    session.refresh(quest)
    
    return quest

@app.get("/leaderboard", tags=["Users"])
async def get_leaderboard(
    session: Annotated[Session, Depends(api_database.get_session)],
    limit: int = 10
):
    """Get the points leaderboard"""
    users = session.exec(
        select(User).order_by(User.points.desc()).limit(limit)
    ).all()
    
    # Format the response
    leaderboard = [
        {
            "username": user.username,
            "full_name": user.full_name or "Anonymous",
            "level": user.level,
            "completed_quests": user.completed_quests,
            "points": user.points
        }
        for user in users
    ]
    
    return {
        "leaderboard": leaderboard,
        "total_users": len(leaderboard)
    }
