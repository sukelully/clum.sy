// Import Ball class
import Ball from './ball.js';

const canvas = document.getElementById('myCanvas');
const ctx = canvas.getContext('2d');
const ballSpeed = 4;
const balls = [];

// Animation loop
const update = () => {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    for (const ball of balls) {
        ball.draw(ctx);
        ball.move();
        ball.collideWall(canvas);
        // for (let i = 0; i < balls.length; i++) {
        //     console.log(i);
        // }
    }

    requestAnimationFrame(update);
}

update();

// Handle mouse click event to change ball position
canvas.addEventListener('click', (event) => {
    const mouseX = event.clientX - canvas.offsetLeft;
    const mouseY = event.clientY - canvas.offsetTop;

    // console.log(`x: ${mouseX}, y: ${mouseY}`);

    balls.push(new Ball(mouseX, mouseY, ballSpeed, ballSpeed));
});
