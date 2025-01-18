import streamlit as st
import base64
import os

def get_image_base64(image_path):
    with open(image_path, "rb") as image_file:
        encoded = base64.b64encode(image_file.read()).decode()
    return f"data:image/png;base64,{encoded}"

def load_css(css_file):
    with open(css_file) as f:
        return f'<style>{f.read()}</style>'

# Get file paths
current_dir = os.path.dirname(__file__)
icon_path = os.path.join(current_dir, "icon.png")
css_path = os.path.join(current_dir, "styles", "animation.css")

# Load resources
icon_base64 = get_image_base64(icon_path)
css = load_css(css_path)

# Create animation HTML
animation_html = f"""
{css}
<div class="liquid-animation">
    <img src="{icon_base64}" class="icon" alt="icon">
</div>
"""

# Display the animation
st.set_page_config(layout="wide", initial_sidebar_state="collapsed")

# Hide sidebar
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

st.markdown(animation_html, unsafe_allow_html=True)

def main():
    st.title("Welcome to App")
    # Add app content here

if __name__ == "__main__":
    main()

