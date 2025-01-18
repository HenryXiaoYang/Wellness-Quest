import streamlit as st

# CSS for the liquid animation
liquid_animation = """
<style>
.liquid-animation {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100vh;
    background: white;
    overflow: hidden;
    animation: fadeOut 2s ease-in-out forwards;
    z-index: 9999;
}

.liquid-animation::before,
.liquid-animation::after {
    content: '';
    position: absolute;
    top: -100%;
    width: 200%;
    height: 200%;
    background: #03DAC6;
}

.liquid-animation::before {
    left: -50%;
    border-radius: 45% 45% 45% 45%;
    animation: liquid 2s ease-in-out forwards;
}

.liquid-animation::after {
    left: -55%;
    border-radius: 40% 40% 45% 45%;
    animation: liquid 2s ease-in-out 0.1s forwards;
}

@keyframes liquid {
    0% {
        transform: translateY(-100%) rotate(0deg);
    }
    100% {
        transform: translateY(50%) rotate(10deg);
    }
}

@keyframes fadeOut {
    0% {
        opacity: 1;
    }
    90% {
        opacity: 1;
    }
    100% {
        opacity: 0;
    }
}
</style>

<div class="liquid-animation"></div>
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

