/*
 *
 * hito - hito
 * Kazumi Inada, Aika Eimaeda & Haruka Otsuka
 * - hello@nandenjin.com
 *
 */

import processing.serial.*;
import cc.arduino.*;
Arduino arduino;

import websockets.*;
WebsocketClient wsc;

int WIDTH = 800;
int HEIGHT = 800;

int INPUT_PIN_A = 2;
int INPUT_PIN_B = 3;

int step = 0;
int STEP_LENGTH = 10;

ArrayList<Particle> particles;

int AREA_RADUIS = 300;


int PARTICLES_PER_STEP = 30;
float PARTICLE_NUM_POWER = 0.1;
float PERTICLE_DECAY_POWER = 0.05;

float ACTION_THRESHOLD = 0.002;
float STRENGTH_MAX = 2;

Position INITIAL_POSITION_A;
Position INITIAL_POSITION_B;
float INITIAL_SPEED_LENGTH = 6;
float INITIAL_SPEED_RADIAN_A = radians( -22.5 );
float INITIAL_SPEED_RADIAN_B = radians( -135 - 22.5 );

float INITIAL_SIZE = 60;

int huePosition = 0;

boolean calib = true;


boolean hasNext = false;
float size = 0;
int num = 0;
int col = 0;
float decay = 0;
float speedLength = 0;
float speedRadian = 0;

ArrayList<JSONObject> queues;

void setup() {

  colorMode( HSB );

  // fullScreen();
  size( 800, 800 );

  // arduino = new Arduino( this, Arduino.list()[2], 57600 );

  wsc = new WebsocketClient( this, "ws://localhost:8080" );

  particles = new ArrayList<Particle>();
  queues = new ArrayList<JSONObject>();

  INITIAL_POSITION_A = new Position( -WIDTH / 2, HEIGHT / 2 );
  INITIAL_POSITION_B = new Position( WIDTH / 2, HEIGHT / 2 );

  frameRate( 30 );

}

void draw() {

  pushMatrix();
  translate( width / 2, height / 2 );
  scale( -1, 1 );
  blendMode( ADD );


  background( 0 );

  // println( particles.length );

  for( int i = particles.size() - 1; i >= 0; i-- ) {

    Particle particle = particles.get( i );

    particle.tick();
    particle.render();

    Position p = particle.position;
    float d = sqrt( p.x * p.x + p.y * p.y );

    if( p.x < -WIDTH / 2 || WIDTH / 2 < p.x || p.y < -HEIGHT / 2 || HEIGHT / 2 < p.y )
      particle.size = 0;

    if( particle.size <= 0 ) particles.remove( i );

  }

  if( calib ) {

    fill( 0, 0, 255 );
    ellipse( -WIDTH / 2, -HEIGHT / 2, 120, 120 );
    ellipse( -WIDTH / 2, HEIGHT / 2, 120, 120 );
    ellipse( WIDTH / 2, -HEIGHT / 2, 120, 120 );
    ellipse( WIDTH / 2, HEIGHT / 2, 120, 120 );

  }

  popMatrix();

}

void webSocketEvent( String msg ){

  println( msg );
  JSONObject in = parseJSONObject( msg );

  size = in.getFloat( "size" );
  num = in.getInt( "num" );
  col = in.getInt( "color" );
  decay = in.getFloat( "decay" );
  speedLength = in.getFloat( "speedLength" );
  speedRadian = in.getFloat( "speedRadian" );

  float x = in.getFloat( "x" );
  float y = in.getFloat( "y" );

  Particle particle = new Particle();
  particle.position.setXY( x, y );

  particle.speed.setXY( speedLength * cos( speedRadian ), speedLength * sin( speedRadian ) );
  particle.size = size;
  particle.col = col;
  particle.decay = decay;

  particles.add( particle );

}

void keyPressed() {

  calib = !calib;

}
