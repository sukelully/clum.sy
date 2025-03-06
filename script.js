// Import Ball class
import Ball from './ball.js';

const canvas = document.getElementById('myCanvas');
const ctx = canvas.getContext('2d');
const ballSpeed = 4;


// const ball = new Ball(50, 50, 4, 4);
const balls = [];
// balls.push(new Ball(50, 50, 4, 4));

// Animation loop
const update = () => {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    if (balls[0]) {
        for (const ball of balls) {
            ball.draw(ctx);
            ball.move();
            ball.collideWall(canvas);
        }
    }

    requestAnimationFrame(update);
}

update();

// Handle mouse click event to change ball position
canvas.addEventListener('click', (event) => {
    const mouseX = event.clientX - canvas.offsetLeft;
    const mouseY = event.clientY - canvas.offsetTop;

    console.log(`x: ${mouseX}, y: ${mouseY}`);

    balls.push(new Ball(mouseX, mouseY, ballSpeed, ballSpeed));

    // ball.x = mouseX;  // Update the ball's x position
    // ball.y = mouseY;  // Update the ball's y position
});
