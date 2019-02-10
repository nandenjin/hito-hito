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

int INPUT_PIN_A = 2;
int INPUT_PIN_B = 3;

int step = 0;
int STEP_LENGTH = 10;

ArrayList<Particle> particles;

int AREA_RADUIS = 300;

int PARTICLES_PER_STEP = 10;
float PARTICLE_NUM_POWER = 0.1;
float PERTICLE_DECAY_POWER = 0.05;

float ACTION_THRESHOLD = 0.005;

Position INITIAL_POSITION_A;
Position INITIAL_POSITION_B;
float INITIAL_SPEED_LENGTH = 3;
float INITIAL_SPEED_RADIAN_A = radians( 30 );
float INITIAL_SPEED_RADIAN_B = radians( 210 );

float INITIAL_SIZE = 60;

int huePosition = 0;


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

  float pra = radians( 210 );
  INITIAL_POSITION_A = new Position( AREA_RADUIS * cos( pra ), AREA_RADUIS * sin( pra ) );

  float prb = radians( 30 );
  INITIAL_POSITION_B = new Position( AREA_RADUIS * cos( prb ), AREA_RADUIS * sin( prb ) );

  frameRate( 60 );

}

void draw() {

  pushMatrix();
  translate( width / 2, height / 2 );
  blendMode( ADD );

  println( hasNext );

  for( int i = queues.size() - 1; i >= 0; i-- ) {

    JSONObject in = queues.get( i );

    size = in.getFloat( "size" );
    num = in.getInt( "num" );
    col = in.getInt( "color" );
    decay = in.getFloat( "decay" );
    speedLength = in.getFloat( "speedLength" );
    speedRadian = in.getFloat( "speedRadian" );

    Particle particle = new Particle();
    particle.position.set( INITIAL_POSITION_A.clone() );

    float sl = INITIAL_SPEED_LENGTH + random( 3 );
    float sr = INITIAL_SPEED_RADIAN_A + random( -0.5, 0.5 );

    particle.speed.setXY( sl * cos( sr ), sl * sin( sr ) );
    particle.size = size;
    particle.col = col;
    particle.decay = decay;

    particles.add( particle );

    queues.remove( i );

  }

  background( 0 );

  // println( particles.length );

  for( int i = particles.size() - 1; i >= 0; i-- ) {

    Particle particle = particles.get( i );

    particle.tick();
    particle.render();

    Position p = particle.position;
    float d = sqrt( p.x * p.x + p.y * p.y );

    Position f = new Position( -p.x / d, -p.y / d );

    if( d > AREA_RADUIS ) {
      particle.speed.add( f );
    }

    if( particle.size <= 0 ) particles.remove( i );

  }

  popMatrix();

}

void webSocketEvent( String msg ){

  println( msg );
  JSONObject in = parseJSONObject( msg );

  queues.add( in );

}
