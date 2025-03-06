// Import Ball class
import Ball from './ball.js';

const canvas = document.getElementById('myCanvas');
const ctx = canvas.getContext('2d');
const ballSpeed = 1;
const balls = [];

const clearBtn = document.getElementById('clear-btn');

const clearBalls = () => {
    balls.splice(0, balls.length);
}

const update = () => {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    for (let i = 0; i < balls.length; i++) {
        balls[i].move();
        balls[i].collideWall(canvas);

        // Reset ball color
        // balls[i].color = 'black';

        // Check for collisions with other balls
        for (let j = i + 1; j < balls.length; j++) {
            if (balls[i].isCollide(balls[j])) {
                console.log('collision!');
            } else {
                balls[i].color = 'black';
                balls[j].color = 'black';
            }
        }

        balls[i].draw(ctx);
    }

    requestAnimationFrame(update);
};

update();

// Handle mouse click event to change ball position
canvas.addEventListener('click', (event) => {
    const mouseX = event.clientX - canvas.offsetLeft;
    const mouseY = event.clientY - canvas.offsetTop;
    const randomSpeed = Math.random() * 4;

    console.log(`x: ${mouseX}, y: ${mouseY}`);

    balls.push(new Ball(mouseX, mouseY, ballSpeed, ballSpeed));
});

clearBtn.addEventListener('click', clearBalls);