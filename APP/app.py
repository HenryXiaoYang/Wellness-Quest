import streamlit as st
import base64
import os

# Function to load and encode the image
def get_image_base64(image_path):
    with open(image_path, "rb") as image_file:
        encoded = base64.b64encode(image_file.read()).decode()
    return f"data:image/png;base64,{encoded}"

# Get the base64 encoded image
icon_path = os.path.join(os.path.dirname(__file__), "icon.png")
icon_base64 = get_image_base64(icon_path)

# CSS for the liquid animation
liquid_animation = f"""
<style>
.liquid-animation {{
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100vh;
    background: white;
    overflow: hidden;
    animation: fadeOut 4s ease-in-out forwards;
    z-index: 9999;
    display: flex;
    justify-content: center;
    align-items: center;
}}

.icon {{
    width: 150px;
    height: 150px;
    position: absolute;
    z-index: 10000;
    animation: iconFade 4s ease-in-out forwards;
    opacity: 0;
}}

.liquid-animation::before,
.liquid-animation::after {{
    content: '';
    position: absolute;
    top: -100%;
    width: 200%;
    height: 200%;
    background: #03DAC6;
    opacity: 0;
    animation: liquid 4s ease-in-out forwards,
               fadeIn 0.3s ease-in-out forwards;
}}

.liquid-animation::before {{
    left: -50%;
    border-radius: 45% 45% 45% 45%;
}}

.liquid-animation::after {{
    left: -55%;
    border-radius: 40% 40% 45% 45%;
    animation-delay: 0.1s;
}}

@keyframes fadeIn {{
    0% {{
        opacity: 0;
    }}
    100% {{
        opacity: 1;
    }}
}}

@keyframes liquid {{
    0% {{
        transform: translateY(-100%) rotate(0deg);
    }}
    100% {{
        transform: translateY(50%) rotate(10deg);
    }}
}}

@keyframes fadeOut {{
    0% {{
        opacity: 1;
    }}
    90% {{
        opacity: 1;
    }}
    100% {{
        opacity: 0;
    }}
}}

@keyframes iconFade {{
    0% {{
        opacity: 0;
        transform: scale(0.5);
    }}
    20% {{
        opacity: 1;
        transform: scale(1);
    }}
    80% {{
        opacity: 1;
        transform: scale(1);
    }}
    100% {{
        opacity: 0;
        transform: scale(1.2);
    }}
}}
</style>

<div class="liquid-animation">
    <img src="{icon_base64}" class="icon" alt="icon">
</div>
"""

# Display the animation
st.set_page_config(layout="wide", initial_sidebar_state="collapsed")
st.markdown("""
    <style>
        [data-testid="stSidebar"][aria-expanded="true"]{
            display: none;
        }
        [data-testid="stSidebar"][aria-expanded="false"]{
            display: none;
        }
    </style>
""", unsafe_allow_html=True)
st.markdown(liquid_animation, unsafe_allow_html=True)

# app content (will appear after animation)
def main():
    st.title("Welcome to App")
    # Add app content here

if __name__ == "__main__":
    main()

