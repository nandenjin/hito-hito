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

import processing.sound.*;
SoundFile file;

int WIDTH = 800;
int HEIGHT = 800;

int INPUT_PIN_A = 0;
int INPUT_PIN_B = 1;

SignalProcessor sigA;
SignalProcessor sigB;

int step = 0;
int STEP_LENGTH = 5;

ArrayList<Particle> particles;

int AREA_RADUIS = 300;

int PARTICLES_PER_STEP = 30;
float PARTICLE_NUM_POWER = 0.1;
float PERTICLE_DECAY_POWER = 0.05;

float ACTION_THRESHOLD = 0.003;
float STRENGTH_MAX = 2;

Position INITIAL_POSITION_A;
Position INITIAL_POSITION_B;
float INITIAL_SPEED_LENGTH = 6;
float INITIAL_SPEED_RADIAN_A = radians( -15 );
float INITIAL_SPEED_RADIAN_B = radians( -135 - 30 );

float INITIAL_SIZE = 60;

int huePosition = 0;

boolean calib = true;

SoundFile soundFile;
float soundAmp = 0;

void setup() {

  colorMode( HSB, 100 );

  //fullScreen();
  size( 800, 800 );

  println( Arduino.list() );
  // arduino = new Arduino( this, Arduino.list()[7], 57600 );

  wsc = new WebsocketClient( this, "ws://localhost:8080" );

  sigA = new SignalProcessor();
  sigB = new SignalProcessor();

  particles = new ArrayList<Particle>();

  INITIAL_POSITION_A = new Position( -WIDTH / 2, HEIGHT / 2 );
  INITIAL_POSITION_B = new Position( WIDTH / 2, HEIGHT / 2 );

  soundFile = new SoundFile(this, "loop.wav");
  soundFile.amp(0);
  soundFile.loop();

  frameRate( 30 );

}

void draw() {

  pushMatrix();
  translate( width / 2, height / 2 );
  blendMode( ADD );

   // float a = (float)arduino.analogRead( INPUT_PIN_A ) / 1024;
   // float b = (float)arduino.analogRead( INPUT_PIN_B ) / 1024;
   //
   // print(a);
   // print(' ');
   // println(b);

  float a = (float)mouseX / width;
  float b = (float)mouseY / width;

  sigA.push( a );
  sigB.push( b );

  float strengthA = min( sigA.diff() / ACTION_THRESHOLD, STRENGTH_MAX );
  float strengthB = min( sigB.diff() / ACTION_THRESHOLD, STRENGTH_MAX );

  float vA = sigA.avg();
  float vB = sigB.avg();

  println( vB );

  background( 0 );

  if( step == 0 && strengthA >= 1 && vA >= 0.5 ) {

    int num = (int)( ( PARTICLES_PER_STEP + random( PARTICLES_PER_STEP / 2 ) ) * ( strengthA * PARTICLE_NUM_POWER ) );

    for( int i = 0; i < num; i++ ) {

      Particle particle = new Particle();
      particle.position.set( INITIAL_POSITION_A.clone() );

      float sl = INITIAL_SPEED_LENGTH * ( ( strengthA - 1 ) * 0.1 + 1 ) + random( -1.5, 1.5 );
      float sr = INITIAL_SPEED_RADIAN_A + random( - PI / 4, PI / 4 );

      float decay = strengthA * PERTICLE_DECAY_POWER;
      decay = min( max( decay, 0.3 ), 0.8 );

      particle.speed.setXY( sl * cos( sr ), sl * sin( sr ) );
      particle.size = INITIAL_SIZE + random( INITIAL_SIZE / 2 );
      particle.col = color( huePosition + 60, 255, 255 );
      particle.decay = decay;
      particle.blinkOffset = PI;

      particles.add( particle );

      JSONObject j = new JSONObject();
      j.setInt( "num", num );
      j.setFloat( "x", particle.position.x );
      j.setFloat( "y", particle.position.y );
      j.setFloat( "speedLength", sl );
      j.setFloat( "speedRadian", sr );
      j.setFloat( "blinkOffset", particle.blinkOffset );
      j.setFloat( "size", particle.size );
      j.setFloat( "color", particle.col );
      j.setFloat( "decay", decay );

      wsc.sendMessage( j.toString() );

    }

  }


  if( step == 0 && strengthB >= 1 && vB >= 0.5 ) {

    int num = (int)( ( PARTICLES_PER_STEP + random( PARTICLES_PER_STEP / 2 ) ) * ( strengthB * PARTICLE_NUM_POWER ) );

    for( int i = 0; i < num; i++ ) {

      Particle particle = new Particle();
      particle.position.set( INITIAL_POSITION_B.clone() );

      float sl = INITIAL_SPEED_LENGTH * ( ( strengthB - 1 ) * 0.1 + 1 ) + random( -1.5, 1.5 );
      float sr = INITIAL_SPEED_RADIAN_B + random( - PI / 4, PI / 4 );

      float decay = strengthB * PERTICLE_DECAY_POWER;
      decay = min( max( decay, 0.3 ), 0.8 );

      particle.speed.setXY( sl * cos( sr ), sl * sin( sr ) );
      particle.size = INITIAL_SIZE + random( INITIAL_SIZE / 2 );
      particle.col = color( huePosition - 10, 255, 255 );
      particle.decay = decay;
      particle.blinkOffset = 0;

      particles.add( particle );

      JSONObject j = new JSONObject();
      j.setInt( "num", num );
      j.setFloat( "x", particle.position.x );
      j.setFloat( "y", particle.position.y );
      j.setFloat( "speedLength", sl );
      j.setFloat( "speedRadian", sr );
      j.setFloat( "blinkOffset", particle.blinkOffset );
      j.setFloat( "size", particle.size );
      j.setFloat( "color", particle.col );
      j.setFloat( "decay", decay );

      wsc.sendMessage( j.toString() );

    }

  }

  step++;
  if( step >= STEP_LENGTH ) step -= STEP_LENGTH;

  huePosition = floor( ( sin( (float)millis() / 10000 * PI * 2 ) + 1 ) / 2 * 33 );

  // println( particles.length );

  for( int i = particles.size() - 1; i >= 0; i-- ) {

    Particle particle = particles.get( i );

    particle.tick();
    particle.render();

    Position p = particle.position;
    float d = sqrt( p.x * p.x + p.y * p.y );

    if( p.x < -WIDTH / 2 || WIDTH / 2 < p.x || p.y < -HEIGHT / 2 || HEIGHT / 2 < p.y )
      particle.size = 0;

    if( particle._size <= 1 ) particles.remove( i );

  }

  if( calib ) {

    fill( 0, 0, 255 );
    ellipse( -WIDTH / 2, -HEIGHT / 2, 120, 120 );
    ellipse( -WIDTH / 2, HEIGHT / 2, 120, 120 );
    ellipse( WIDTH / 2, -HEIGHT / 2, 120, 120 );
    ellipse( WIDTH / 2, HEIGHT / 2, 120, 120 );

  }

  soundAmp += ( min( (float)particles.size() / 10, 1.0 ) - soundAmp ) / 40;
  soundFile.amp( soundAmp );

  popMatrix();

}

void keyPressed() {

  calib = !calib;

}
