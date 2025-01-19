import os
import uuid
from random import randint

from dotenv import load_dotenv
from fastapi import HTTPException, status
from openai import AsyncClient
from pydantic import BaseModel

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
        if randint(0, 9) > 4:  # Modify the prompt may fail, so using random is better
            pref_str = ", ".join(preferences) if preferences else "no preference"
        else:
            pref_str = "no preference"

        response = await client.beta.chat.completions.parse(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "developer",
                    "content": "You are a creative nutritionist who prioritizes diverse, healthy meal recommendations. You must follow these strict rules:\n"
                               "1. Generate unique dishes each time.\n"
                               "2. Dish description should not be more than 25 words, use common english vocabulary in the dish name.\n"
                               "3. Recipe should be long and detailed. With ingredients, list of detailed preparation steps, and list of detailed cooking instructions.\n"
                               "4. Suggestions should consider user preferences, but ignore the unhealthy preferences.\n"
                               "6. Include a mix of vegetarian and non-vegetarian options\n"
                               "7. Ensure dishes are from different cuisines and cultures\n"
                },
                {
                    "role": "user",
                    "content": f"Generate {count} nutrition dishes. This person is a {user_age} year old {user_gender} with preferences ({pref_str}). Avoid common dishes like salmon or quinoa. Ensure each recipe is long and detailed, including ingredients, preparation steps, cooking instructions, and sentence starts with a newline."
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
        if randint(0, 9) > 2:  # Modify the prompt may fail, so using random is better
            pref_str = ", ".join(preferences) if preferences else "no preference"
        else:
            pref_str = "no preference"

        response = await client.beta.chat.completions.parse(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "developer",
                    "content": "You are an innovative fitness trainer who creates diverse and effective exercise plans. Follow these strict rules:\n"
                               "1. Generate unique exercises each time - avoid common defaults like basic pushups or jogging\n"
                               "2. Description should not be more than 25 words, and use common vocabulary in the name.\n"
                               "3. Suggestions should consider user preferences, but ignore the unhealthy preferences.\n"
                               "4. Include a mix of:\n"
                               "   - Strength training\n"
                               "   - Cardio exercises\n"
                               "   - Flexibility work\n"
                               "   - Balance training\n"
                               "5. Vary intensity levels from beginner to advanced\n"
                               "6. Include both equipment-based and bodyweight exercises\n"
                               "7. Ensure exercises are age-appropriate and safe"
                },
                {
                    "role": "user",
                    "content": f"Create {count} unique and diverse exercises for a {user_age} year old {user_gender}. While they mentioned these preferences: {pref_str}, focus on providing a well-rounded fitness experience."
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
        if randint(0, 9) > 4:  # Modify the prompt may fail, so using random is better
            pref_str = ", ".join(preferences) if preferences else "no preference"
        else:
            pref_str = "no preference"

        response = await client.beta.chat.completions.parse(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "developer",
                    "content": "You are an expert sleep and recovery specialist who creates holistic rest plans. Follow these strict rules:\n"
                               f"1. Generate {count} rest plans only.\n"
                               "2. Description should use common vocabulary.\n"
                               "3. Generate unique rest activities each time - avoid defaulting to basic suggestions like 'take a nap'\n"
                               "4. Suggestion should consider user preferences, but ignore unhealthy preferences\n"
                               "5. Include but not limiting to:\n"
                               "   - Physical rest activities\n"
                               "   - Mental relaxation techniques\n"
                               "   - Stress-reduction practices\n"
                               "   - Sleep hygiene improvements\n"
                               "6. Include both active and passive rest activities\n"
                               "7. Ensure rest activities are age-appropriate and safe"
                },
                {
                    "role": "user",
                    "content": f"Create {count} innovative rest and recovery plans for a {user_age} year old {user_gender}. While they mentioned these preferences: {pref_str}, prioritize scientifically-backed rest strategies."
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
