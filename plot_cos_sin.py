import numpy as np
import matplotlib.pyplot as plt

# Define the function
def plot_cos_plus_sin():
    t = np.linspace(0, 2 * np.pi, 100)
    y = np.cos(t) + np.sin(t)

    plt.plot(t, y)
    plt.title('Plot of cos(t) + sin(t)')
    plt.xlabel('t')
    plt.ylabel('cos(t) + sin(t)')
    plt.grid(True)
    plt.show()

if __name__ == "__main__":
    plot_cos_plus_sin()
