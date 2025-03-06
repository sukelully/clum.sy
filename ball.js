class Ball {
    constructor(x, y, dx, dy) {
        this.x = x;
        this.y = y;
        this.radius = 20;
        this.dx = dx;
        this.dy = dy;
        this.color = 'black';
    }

    move() {
        this.x += this.dx;
        this.y += this.dy;
    }

    draw(ctx) {
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
        ctx.fillStyle = this.color;
        ctx.fill();
        ctx.closePath();
    }

    // Bounce off walls of canvas
    collideWall(canvas) {
        if (this.x + this.radius > canvas.width || this.x - this.radius < 0) {
            this.dx = -this.dx; // Reverse horizontal direction
        }
        if (this.y + this.radius > canvas.height || this.y - this.radius < 0) {
            this.dy = -this.dy; // Reverse vertical direction
        }
    }

    // Check for collisions with other balls
    isCollide(ball) {
        const distX = this.x - ball.x;
        const distY = this.y - ball.y;
        const distance = Math.sqrt(distX * distX + distY * distY);

        if (distance < this.radius + ball.radius) {
            this.color = 'red';
            ball.color = 'red';

            this.dx = -this.dx;
            ball.dx = -ball.dx;
            this.dy = -this.dy;
            ball.dy = -ball.dy;
        }

        return distance < this.radius + ball.radius;
    }
}

export default Ball;
