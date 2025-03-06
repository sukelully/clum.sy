// Ball.js
class Ball {
    constructor(x, y) {
        this.x = x;
        this.y = y;
        this.radius = 20;
        this.dx = 4;
        this.dy = 4;
        this.color = 'red';
    }

    // Move the ball
    move() {
        this.x += this.dx;
        this.y += this.dy;
    }

    // Draw the ball
    draw(ctx) {
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
        ctx.fillStyle = this.color;
        ctx.fill();
        ctx.closePath();
    }
}

// Export the Ball class
export default Ball;
