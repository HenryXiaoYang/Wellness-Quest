<div align="center">
    <p align="center">
        <img src="https://raw.githubusercontent.com/HenryXiaoYang/Wellness-Quest/refs/heads/main/APP/assets/icon.png" alt="Wellness Quest Logo" width="200" height="200">
        <h1 align="center">Wellness Quest</h1>
    </p>
</div>

## ⭐️ Inspiration

Both of us are computer guys who can sit in front of a computer 24 hours a day to do programming and coding. We realized this is not a healthy lifestyle. After digging deeper into the concept of a healthy lifestyle and the inspiration prompt of `community impact,` we decided to create an application that can help us, our neighborhood, and even everyone across the globe to be healthy and well-being.

Before we start, some problems have not been solved...

### 🤔 The Problem We're Solving

According to the National Library of Medicine, one-third of adults suffer from chronic conditions. The advancement of technology and electronic devices has led to the development of mobile health apps for managing health behavior, such as lifestyle and mental well-being. Nevertheless, the significant issue of users frequently abandoning these apps hinders their potential effectiveness.

> A median of **70%** of users stop using the app within the first 100 days.

_WHY?_ After researching and making connections to our own experience, we sum up these points:

- The app focuses on **NUMBER** rather than **MOTIVATION**.
- The app is not **PERSONALIZED** to the user.
- The app is not **ENGAGING**.
- The app is not **FUN**.

### ⭕️ Our Solution

Wellness-Quest was born from the intersection of two powerful concepts:
- The awarding for completing `quests` to level up your wellness.
- Harness the power of AI to personalize quests to fit your wellness goals.

### 🎮 Why Gaming Elements?

We drew inspiration from:
- 🎮 The addictive progression systems of _RPG games_
- 🏆 The satisfaction of achieving _in-game achievements_
- 👥 The power of _multiplayer cooperation and competition_
- 🎯 The clarity of _quest-based goal_

## ❓ What does it do?

`Wellness Quest` is an APP that transforms your health and fitness goals into exciting quests. Track your progress, complete quests, and level up your well-being while competing within a community in a fun, gamified experience.

### 🎮 How It Works

`Wellness Quest` turns your wellness journey into an epic adventure where you accept and complete quests to level up your wellness! Here's how:

#### 🗺️ Quest System

**Quests** are generated by AI based on your preferences, age, and gender. The goal is to complete the quest to level up your wellness.

#### ✨ Quests

There are three types of quests:
- **Nutrition**: Nutrition-related questions, such as eating healthy, tracking calories, and meal planning.
- **Exercise**: Quests related to exercise, such as working out tracking progress.
- **Rest**: Quests related to rest, such as getting enough sleep, meditating, and relaxing.

## ⚙️ How we built it

- _Henry Yang_ is responsible for the backend, fine-tuning the AI, beautifying the APP UI, documents, and deploying.
- _Sunny Zhu_ is responsible for the front end, designing the APP UI, implementing UI, and making the video.

This project's backend is built using [`FastAPI`](https://fastapi.tiangolo.com) (Python). It manages the user by obtaining, storing, and returning the profile and preferences. It is also responsible for managing all the generated quests. The OpenAI API, specifically the GPT-4o model, powers the generation of quests based on user preferences, age, and gender. The AI model is heavily prompted to generate personalized quests for the user and is easy to render on the front end.

On the other hand, the front end is built using [`Flutter`](https://docs.flutter.dev) (Dart). The app is designed to be simple and easy to use, focusing on the user experience. It sends requests to the backend to authenticate and obtain quests. The app is also responsible for rendering the quests and the leaderboard.

## 🏆 Challenges we ran into

We started by writing the backend. The first challenge we faced was user authentication. The FastAPI authentication uses a Bearer token. It stores the password by hashing it and checks its validity by comparing the hash of the inputted password with the stored hash. Here are the problems: 1. We don't know how to hash the password. 2. How to keep the password safe? 3. Where to store all the information. Fortunately, the Python community is powerful. After surfing through FastAPI documentation and reading some posts in Stack Overflow, we wrote the authentication with help using AI. The hashing of passwords can be done using a Python package named `passlib`. We can store the password safely in a SQLite database. Python accesses the database by using the `sqlmodel` package.

Another challenge is the ChatGPT prompt. Initially, we passed the user's preferences directly to the ChatGPT and let it "Use user's preferences as reference." to generate food. However, the ChatGPT directly answers with the user's preferences. This is like answering a question with the question itself. We don't want, as the food generated should be diverse. Thus, we modified our prompt over and over again, prompting ChatGPT there is a 50% chance of using the user's preferences and 50% not to. This failed. Next, we start to modify the `temperature` parameter. As the `temperature` increases, ChatGPT is more creative and random. This also fails, as ChatGPT answers with irrelevant things. (You can see our attempts via Github commit history.) Finally, we interfere with the generation by using random. There is a 50% chance that we will pass the user's preference to the ChatGPT. When passed, ChatGPT answers with dishes related to the user's preference. When not passed, ChatGPT answers with dishes randomly. (Still healthy) From an outsider's perspective, the AI sometimes generates dishes according to preference, sometime not. This achieves what we want.

Moving on to the front end, initially, we plan to use the Python package [`streamlit`](https://streamlit.io) to build a web app. However, when we finished designing the UI on paper and started to implement it in code, problems occurred. Streamlit is used initially to visualize scientific data. It has poor compatibility with multipage applications. There are some solutions, but they will not work for our project, as we need a lot of page jumps. Fortunately, Sunny had much experience with the UI development kit [`Flutter`](https://docs.flutter.dev), using the `Dart` language. `Flutter` accesses the back-end API with HTTP protocol, which works perfectly.

While Sunny is writing the authentication request to the back end, he says that the back end always reports a `400 Bad Request` error. We start to debug. The problem is that the server accepts `application/x-www-form-urlencoded`. However, we sent `application/json`. The server does not accept this. We searched online for how to send `application/x-www-form-urlencoded` with `Dart`. Thanks to community support, the solution is quickly found, and the bearer token is successfully retrieved.

## 🎊 Accomplishments that we're proud of

We are most proud that we transformed our concept into a fully functional app, Wellness Quest, that effectively gamifies health and wellness goals, making them engaging and enjoyable for users. We are also proud that we can generate quests based on user's preferences, which enhances their experience and increases their motivation to use our app. We are also proud of creating a beautiful app with Flutter, ensuring that users can easily navigate and engage with its features, and the celebration animation is so cool! 

## 📚 What we learned

Both of us learned a lot of things.

We learned:

- How to write authentication in FastAPI
- How to get authenticated in Dart
- How to use a database effectively and what is ORM
- How to save the Python objects (quests and users) in a database
- How to prompt and configure the ChatGPT
- How to use Docker to deploy a FastAPI project
- How to use AI during programming to increase efficiency!
- How to connect the front end with the back end with API
- Deeper understanding with API

- How to use bearer token

- How to make a complete project

## 🚀 What's next for Wellness Quest

🗺️ Road Map:

- **Beautify the UI**: Enhance the visual representation and implement animation to make navigation smoother
- **Community sharing and posting**: Features for users to share their achievements and quests
- **Expanded quest types**: New quests type such as mental wellness (?)
- **Integration with wearable devices**: Add integrations with fitness trackers and smartwatches for real-time tracking
- **Enhancing gamification**: Introduce badges, titles, and rewards for completing quests or reaching milestones.
- **Localization**: Translate the app into multiple languages for more users.

## 🚀 Getting Started

1. Clone the repository
2. Install dependencies
3. Run the API backend
4. Run the Flutter app
5. Start your wellness journey!

## 💻 Installation

### API Backend

#### Using Docker

```bash
docker build -t wellness-quest-api -f API-Dockerfile .
docker volume create wellness-quest-data
docker run -d -p 1111:8000 --name wellness-quest-api-container -v wellness-quest-data:/app wellness-quest-api
```

#### Using Python

```bash
pip install -r requirements.txt
uvicorn main:app --reload
```

### Flutter App

#### Using Flutter

1. Install Flutter by following the [official installation guide](https://docs.flutter.dev/get-started/install)

2. Navigate to the app directory:

```bash
cd APP
```

3. Set Backend URL:

File at `APP/assets/config.json`:

```json
{
  "backend_url": "http://your-api-url"
}
```

4. Get dependencies:

```bash
flutter pub get
```

5. Run the app:

### For Development

```bash
flutter run
```

### For Production Build

#### Android

```bash
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

#### iOS

```bash
flutter build ios --release
```

Then use Xcode to archive and distribute the app.

#### Web

```bash
flutter build web --release
```

The web build will be available in the `build/web` directory.
