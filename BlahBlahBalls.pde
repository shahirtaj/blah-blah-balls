
/**
 * BlahBlahBalls
 *
 * Blah Blah Balls is a casual creator that allows users to create fun 
 * drawings while also playing a modified version of the classic "Brick 
 * Breaker" game. Users can add more balls to the canvas by clicking, and 
 * they are kept engaged and excited to create by experiencing unique 
 * combinations of balls and patterns, and facing the challenge of trying 
 * to prevent their balls from dropping below the screen by moving the paddle 
 * across the canvas. The project also offers the option to toggle the bottom 
 * boundary (by pressing "B" on the keyboard), which keeps the balls bouncing 
 * around the screen, and can produce interesting results when experimented with. 
 * Finally, users are able to share their art with others by first pausing (by 
 * pressing "SPACE" on the keyboard) and then saving their image (by pressing "S").
 
 * Instructions:
 *   1. Click to release a ball.
 *   2. Move the paddle back and forth across the screen to prevent the ball from
 *      falling below the screen
 *   3. Keep clicking to release more balls from your new mouse position.
 *      Alternatively, tap "B" on your keyboard to keep all balls in bounds.
 *   4. When you are done painting, tap the space bar to pause the screen, and tap
 *      "S" on your keyboard to save your image.
 * Bugs:
 *   Some balls occasionally fall through the top of the paddle.
 *   The trails can sometimes appear too segmented, and can cause some lag.
 
 * Credits:
 *   The Trail's follow() algorithm was copied from the "Follow 3" example in the
 *   Processing documentation (https://processing.org/examples/follow3.html).
 *   The algorithm for having the each mouse click increase the number of Balls was
 *   inspired by the "Action Only Once on mousePressed" post on the Processing forum
 *   (https://forum.processing.org/one/topic/action-only-once-on-mousepressed.html).
 *   The conditionals to have the balls collide with the paddle were inspired by the
 *   "Brick Breaker" sketch by Raghu Vaidyanathan on OpenProcessing
 *   (https://www.openprocessing.org/sketch/134612/).
 *   The Ball's move() algorithm was heavily inspired by the "Bounce" example in the
 *   Processing documentation (https://processing.org/examples/bounce.html).
 *
 * @author Shahir Taj
 * @version 12/21/2019
 */

static final int PADDLE_WIDTH = 200;
static final int PADDLE_HEIGHT = 20;
static final int PADDLE_DEPTH = 12;
static final int BALL_RADIUS = 12;

// Create a Paddle.
Paddle paddle = new Paddle((800/2), (450-PADDLE_HEIGHT));

// Create a Ball.
Ball ball = new Ball((800/2), ((450-PADDLE_HEIGHT)-
                    (PADDLE_HEIGHT/2)-BALL_RADIUS));

// Create a Trail.
Trail trail = new Trail(ball);

// Create an array of Balls.
Ball[] balls = new Ball[500];

// Create an array of Trails.
Trail[] trails = new Trail[500];

// How many Balls we have already created.
int numBalls = 0;

// Whether or not the game is active.
boolean isPlaying = true;

// Whether or not the bottom of the campus is a boundary.
boolean hasBottomBoundary = false;

/**
 * The code inside the setup() function is used to
 * initialize general information about the program.
*/
void setup() {
  // Sets the size of the canvas and specifies the render mode (P3D).
  size(800, 450, P3D);
}

/**
 * The code inside the draw() function runs continuously
 * from top to bottom until the program is stopped.
*/
void draw() {
  // If the game is playing...
  if (isPlaying == true) {
    // Set the background.
    background(255, 255, 255);
    lights();
    paddle.display();
    ball.display();
    
    // If we have at least one Ball...
    if (numBalls >= 1) {
      // Draw all Balls that have been created.
      for (int i = 0; i < numBalls; i++) {
        Ball curBall = balls[i];
        Trail curTrail = trails[i];
        // Set the collision rules.
        curBall.collide();
        curBall.move();
        curBall.display();
        // Have a segmented Trail follow the Ball..
        // The Trail's follow() algorithm was copied from the "Follow 3"
        // example in the Processing documentation.
        curTrail.follow(0, curBall.xPos, curBall.yPos);
        for (int j = 0; j < curTrail.xPos.length - 1; j++) {
          curTrail.follow(j + 1, curTrail.xPos[j], curTrail.yPos[j]);
        }
      }
  
      paddle.move();
      paddle.display();
    }
  }
}

/**
 * The code inside the keyPressed() function every
 * time a specific key is pressed.
*/
void keyPressed() {
  // If the spacebar is pressed...
  if ((key == ' ')) {
    // Pause/unpause the game.
    isPlaying = !isPlaying;
  }
  
  // If "B" is pressed and the game is not paused...
  if (((key == 'B') || (key == 'b')) && isPlaying == true) {
    // Toggle the bottom boundary.
    hasBottomBoundary = !hasBottomBoundary;
  }
  
  // If "S" is pressed and the game is paused...
  if (((key == 'S') || (key == 's')) && isPlaying == false) {
    // Save the current image.
    saveFrame("blahblahballs-######.png");
  }
}

/**
 * The code inside the mousePressed() function every
 * time the mouse is pressed.
*/
void mousePressed() {
  // The algorithm for having the each mouse click increase the number 
  // of Balls was inspired by the "Action Only Once on mousePressed" 
  // post on the Processing forum.
  
  // If the game is active...
  if (isPlaying == true) {
    // If we have no Balls.
    if (numBalls == 0) {
      balls[numBalls] = ball;
      trails[numBalls] = trail;
    } else {
      // Create a new Ball and Trail at the current Paddle position.
      Ball newBall = new Ball(mouseX, ((450-PADDLE_HEIGHT)-
        (PADDLE_HEIGHT/2)-BALL_RADIUS));
      Trail newTrail = new Trail(newBall);
      balls[numBalls] = newBall;
      trails[numBalls] = newTrail;
    }

    numBalls++;
  }
}

class Paddle {
  // The position of this Paddle.
  private float xPos;
  private float yPos;
  
  // How much red, green, and blue this Paddle has.
  private float rVal;
  private float gVal;
  private float bVal;

  Paddle(float xPos, float yPos) {
    this.xPos = xPos;
    this.yPos = yPos;
    
    // Randomize our color.
    rVal = random(0, 255);
    gVal = random(0, 255);
    bVal = random(0, 255);
  }

  void display() {
    pushMatrix();
    translate(xPos, yPos, 0);
    fill(rVal, gVal, bVal);
    noStroke();
    // Draws a box on the screen to represent our Paddle.
    box(PADDLE_WIDTH, PADDLE_HEIGHT, PADDLE_DEPTH);
    popMatrix();
  }

  void move() {
    // Updates our position based on mouse position.
    if (mouseX <= (PADDLE_WIDTH / 2)) {
      xPos = (PADDLE_WIDTH / 2) + 1;
    } else if (mouseX >= width - (PADDLE_WIDTH / 2)) {
      xPos = width - (PADDLE_WIDTH / 2);
    } else {
      xPos = mouseX;
    }
  }
}

class Ball {
  // The position of this Ball.
  private float xPos;
  private float yPos;
  
  // How much red, green, and blue this Paddle has.
  private float rVal;
  private float gVal;
  private float bVal;
  
  // How fast/and in what direction this Ball moves.
  private float xVel;
  private float yVel;

  Ball(float xPos, float yPos) { 
    this.xPos = xPos;
    this.yPos = yPos;
    
    // Randomize our color.
    rVal = random(0, 255);
    gVal = random(0, 255);
    bVal = random(0, 255);
    
    // Randomize our velocity.
    xVel = random(-5, 5);
    yVel = random(4, 10);
  }

  void display() {
    pushMatrix();
    translate(xPos, yPos, 0);
    fill(rVal, gVal, bVal);
    noStroke();
    // Draws a sphere on the screen to represent our Ball.
    sphere(BALL_RADIUS);
    popMatrix();
  }

  void collide() {
    // The conditionals to have the balls collide with the paddle
    // were inspired by the "Brick Breaker" sketch by Raghu
    // Vaidyanathan on OpenProcessing.
    
    // If this Ball collides with the top of the paddle...
    if ((yPos + BALL_RADIUS) == (paddle.yPos - (PADDLE_HEIGHT / 2)) && 
      (xPos + BALL_RADIUS) >= (paddle.xPos - (PADDLE_WIDTH / 2)) && 
      (xPos + BALL_RADIUS) <= (paddle.xPos + (PADDLE_WIDTH / 2))) {
      yVel *= -1;
    // If this Ball collides with the bottom of the paddle...
    } else if ((yPos - BALL_RADIUS) == (paddle.yPos + (PADDLE_HEIGHT / 2)) && 
      (xPos + BALL_RADIUS) >= (paddle.xPos - (PADDLE_WIDTH / 2)) && 
      (xPos + BALL_RADIUS) <= (paddle.xPos + (PADDLE_WIDTH / 2))) {
      yVel *= -1;
    }   
  }

  void move() {
    // The Ball's move() algorithm was heavily inspired by the
    // "Bounce" example in the Processing documentation.
    
    // Updates position based on velocity.
    xPos += xVel;
    yPos += yVel;
    // If this Ball collides with the right wall...
    if (xPos + BALL_RADIUS > width) {
      xVel *= -1;
    // If this Ball collides with the left wall...
    } else if (xPos - BALL_RADIUS < 0) {
      xVel *= -1;
    }
    
    // If this Ball collides with the top wall...
    if (yPos - BALL_RADIUS < 0) {
      yVel *= -1;
    // If this Ball collides with the bottom "wall"...
    } else if ((yPos + BALL_RADIUS) > height && hasBottomBoundary == true) {
      yVel *= -1;
    }
  }
}

class Trail {
  // The positions of this Trail's segments.
  private float[] xPos =  new float[(int)random(21,39)];
  private float[] yPos = new float[xPos.length];
  
  // The length of a single segment.
  private float segLength;
  
  // How much red, green, and blue this Paddle has.
  private float rVal;
  private float gVal;
  private float bVal;
  
  // The Ball that this Trail follows.
  private Ball ball;

  Trail(Ball ball) {
    // Store a reference to the parent Ball.
    this.ball = ball;
    
    // Set the segment length.
    segLength = xPos.length / 2;
    
    // Randomize our color.
    rVal = this.ball.rVal;
    gVal = this.ball.gVal;
    bVal = this.ball.bVal;
  }

  void display(float xPos, float yPos, float angle) {
    pushMatrix();
    translate(xPos, yPos, 0);
    rotate(angle);
    fill(rVal, gVal, bVal);
    noStroke();
    // Draws a box on the screen to represent our Trail.
    box(segLength, 5, 5);
    popMatrix();
  }

  void follow(int i, float xPos, float yPos) {
    // The Trail's follow() algorithm was copied from the "Follow 3"
    // example in the Processing documentation.
        
    // Determines the positions and angles of each segment in this Trail.
    float dx = xPos - this.xPos[i];
    float dy = yPos - this.yPos[i];
    float angle = atan2(dy, dx);
    this.xPos[i] = xPos - cos(angle) * segLength;
    this.yPos[i] = yPos - sin(angle) * this.segLength;
    this.display(this.xPos[i], this.yPos[i], angle);
  }
}
