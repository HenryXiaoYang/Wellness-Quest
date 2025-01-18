import streamlit as st

# Set page config
st.set_page_config(page_title="Wellness Quest", page_icon="🌟", layout="wide")

# Custom CSS for styling
st.markdown("""
<style>
    .metric-card {
        background-color: #f0f0f0;
        padding: 20px;
        border-radius: 10px;
        margin: 10px;
    }
    .nutrition-card { background-color: #c2f0c2; }
    .exercise-card { background-color: #ffffc2; }
    .rest-card { background-color: #c2e6ff; }
    .stProgress > div > div > div > div {
        background-color: black;
    }
</style>
""", unsafe_allow_html=True)

# Title
st.title("Wellness Quest")

# Create three columns for each section
def create_metric_section(title, metrics, card_class):
    st.header(title)
    cols = st.columns(2)
    for i, (metric_name, metric_value) in enumerate(metrics.items()):
        with cols[i]:
            st.markdown(f"""
            <div class="metric-card {card_class}">
                <h3>{metric_name}</h3>
                <p>{metric_value}</p>
            </div>
            """, unsafe_allow_html=True)

# Nutrition Section
nutrition_metrics = {
    "Balanced Meals": "3/5",
    "Water (glasses)": "8/15",
}
create_metric_section("Nutrition", nutrition_metrics, "nutrition-card")

# Exercise Section
exercise_metrics = {
    "Minutes": "45/180",
    "Activities": "3",
}
create_metric_section("Exercise", exercise_metrics, "exercise-card")

# Rest Section
rest_metrics = {
    "Sleep Hours": "7/12",
    "Quality": "Good",
}
create_metric_section("Rest", rest_metrics, "rest-card")

# Achievement Progress Bar
st.header("Achieved")
progress = 0.65  # Example fixed progress value
st.progress(progress)

# Complete Quest Button
if st.button("Complete Quest"):
    st.balloons()
    st.success("Congratulations! You've completed your wellness quest for today! 🎉")

