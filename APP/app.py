import streamlit as st

# Set page config
st.set_page_config(page_title="Wellness Quest", page_icon="💚", layout="wide")


# Define the background color and other styles
page_bg_color = """
<style>
[data-testid="stAppViewContainer"] {
    background-color: #03DAC6;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;  /* Full viewport height */
}
</style>
"""
st.markdown(page_bg_color, unsafe_allow_html=True)

# Centered content
st.markdown("""
<div style='text-align: center;'>
    <img src='https://cdn-icons-png.flaticon.com/512/3670/3670297.png' alt='Wellness Icon' width='100' height='100'>
    <h1 style='font-size: 48px; font-weight: bold;'>Wellness Quest</h1>
    <h2 style='font-size: 18px;'>For your healthcare</h2>
</div>
""", unsafe_allow_html=True)
