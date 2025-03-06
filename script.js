// Import Ball class
import Ball from './ball.js';

const canvas = document.getElementById('myCanvas');
const ctx = canvas.getContext('2d');

// Create a ball instance
const ball = new Ball(50, 50);

// Animation loop
const update = () => {
    // Clear the canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Draw the ball
    ball.draw(ctx);

    // Move the ball
    ball.move();

    // Bounce the ball off the walls
    if (ball.x + ball.radius > canvas.width || ball.x - ball.radius < 0) {
        ball.dx = -ball.dx; // Reverse horizontal direction
    }
    if (ball.y + ball.radius > canvas.height || ball.y - ball.radius < 0) {
        ball.dy = -ball.dy; // Reverse vertical direction
    }

    // Call the update function again to create an animation
    requestAnimationFrame(update);
}

// Start the animation
update();

// Handle mouse click event to change ball position
canvas.addEventListener('click', (event) => {
    const mouseX = event.clientX - canvas.offsetLeft;
    const mouseY = event.clientY - canvas.offsetTop;

    console.log(`x: ${mouseX}, y: ${mouseY}`);

    ball.x = mouseX;  // Update the ball's x position
    ball.y = mouseY;  // Update the ball's y position
});
