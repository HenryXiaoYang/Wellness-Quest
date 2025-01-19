import os
import uuid
from openai import AsyncClient
from fastapi import HTTPException, status
from pydantic import BaseModel
from dotenv import load_dotenv

# Load .env
load_dotenv()

# Get key from env var
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
if not OPENAI_API_KEY:
    raise ValueError("OPENAI_API_KEY environment variable is not set")

client = AsyncClient(
    api_key=OPENAI_API_KEY,
    base_url=os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1")
)

class NutritionQuest(BaseModel):
    quest_id: str
    name: str
    description: str
    calories: int
    nutrition: str
    recipe: str

class NutritionQuests(BaseModel):
    Quests: list[NutritionQuest]

class ExerciseQuest(BaseModel):
    quest_id: str
    name: str
    description: str
    instruction: str
    calories: int
    duration: str

class ExerciseQuests(BaseModel):
    Quests: list[ExerciseQuest]


class RestQuest(BaseModel):
    quest_id: str
    name: str
    description: str
    duration: str
    when: str

class RestQuests(BaseModel):
    Quests: list[RestQuest]

def generate_quest_id(prefix: str) -> str:
    unique_part = uuid.uuid4().hex[:8].upper()
    return f"{prefix}-{unique_part}"

async def generate_nutrition_quest(count: int, user_age: int, user_gender: str, preferences: list[str] = None) -> dict:
    try:
        pref_str = ", ".join(preferences) if preferences else "no preference"

        response = await client.beta.chat.completions.parse(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": f"You are a nutritionist creating {count} nutrition dishes for a {user_age} year old {user_gender} client with the following preferences: {pref_str}. Remember: You do not need to follow the preferences, but by 50% chance, the food is related."
                }
            ],
            response_format=NutritionQuests
        )

        result = response.choices[0].message.parsed
        for quest in result.Quests:
            quest.quest_id = generate_quest_id("NUTR")
        return result

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate nutrition quest: {str(e)}"
        )


async def generate_exercise_quest(count: int, user_age: int, user_gender: str, preferences: list[str] = None) -> dict:
    try:
        pref_str = ", ".join(preferences) if preferences else "no preference"

        response = await client.beta.chat.completions.parse(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": f"You are a personal trainer creating {count} exercise for a {user_age} year old {user_gender} client with the following preferences: {pref_str}. Remember: You do not need to follow the preferences, but by 50% chance, the exercise plan is related."
                }
            ],
            response_format=ExerciseQuests
        )
        
        # Add unique quest IDs to each quest
        result = response.choices[0].message.parsed
        for quest in result.Quests:
            quest.quest_id = generate_quest_id("EXER")
        return result

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate nutrition quest: {str(e)}"
        )

async def generate_rest_quest(count: int, user_age: int, user_gender: str, preferences: list[str] = None) -> dict:
    try:
        pref_str = ", ".join(preferences) if preferences else "no preference"

        response = await client.beta.chat.completions.parse(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": f"You are a rest & sleep expert creating {count} daily rest plan for a {user_age} year old {user_gender} client with the following preferences: {pref_str}. Remember: You do not need to follow the preferences, but by 50% chance, the rest plan is related."
                }
            ],
            response_format=RestQuests
        )
        
        # Add unique quest IDs to each quest
        result = response.choices[0].message.parsed
        for quest in result.Quests:
            quest.quest_id = generate_quest_id("REST")
        return result

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate nutrition quest: {str(e)}"
        )
