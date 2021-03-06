 import 'dart:core';

import 'dart:math';





class MadgwickAHRS {

  var samplePeriod;
  var beta;
  var quaternion;

  /**
   * Gets the sample period.
   *
   * @return Sample Period
   */
  double getSamplePeriod() {
    return samplePeriod;
  }

  /**
   * Sets the sample period.
   *
   * @param samplePeriod
   *            Sample period
   */
void setSamplePeriod(double samplePeriod) {
    this.samplePeriod = samplePeriod;
  }

  /**
   * Gets the sample algorithm gain beta.
   *
   * @return Algorithm gain beta
   */
  double getBeta() {
    return beta;
  }

  /**
   * Sets the algorithm gain beta.
   *
   * @param samplePeriod
   *            Algorithm gain beta
   */
   void setBeta(double beta) {
    this.beta = beta;
  }

  /**
   * Gets the quaternion output.
   *
   * @return Quaternion output
   */
  List getQuaternion() {
    return quaternion;
  }

  /**
   * Initializes a new instance of the {@link MadgwickAHRS} class.
   *
   * @param samplePeriod
   *            Sample period.
   */
   MadgwickAHRS(double samplePeriod) {
    this.samplePeriod=samplePeriod;
  }

  /**
   * Initializes a new instance of the {@link MadgwickAHRS} class.
   *
   * @param samplePeriod
   *            Sample period.
   * @param beta
   *            Algorithm gain beta.
   */
  withData(double samplePeriod, double beta) {
    this.samplePeriod = samplePeriod;
    this.beta = beta;
    this.quaternion =  [ 1.0, 0.0, 0.0, 0.0 ];
    print("---------WithData");
  }

  /**
   * Algorithm AHRS update method. Requires only gyroscope and accelerometer
   * data.
   * <p>
   * Optimised for minimal arithmetic. <br>
   * Total ±: 160 <br>
   * Total *: 172 <br>
   * Total /: 5 <br>
   * Total sqrt: 5 <br>
   *
   * @param gx
   *            Gyroscope x axis measurement in radians/s.
   * @param gy
   *            Gyroscope y axis measurement in radians/s.
   * @param gz
   *            Gyroscope z axis measurement in radians/s.
   * @param ax
   *            Accelerometer x axis measurement in any calibrated units.
   * @param ay
   *            Accelerometer y axis measurement in any calibrated units.
   * @param az
   *            Accelerometer z axis measurement in any calibrated units.
   * @param mx
   *            Magnetometer x axis measurement in any calibrated units.
   * @param my
   *            Magnetometer y axis measurement in any calibrated units.
   * @param mz
   *            Magnetometer z axis measurement in any calibrated units.
   */
  void update(double gx, double gy, double gz, double ax, double ay,
      double az, double mx, double my, double mz) {
    double q1 = quaternion[0], q2 = quaternion[1], q3 = quaternion[2], q4 = quaternion[3]; // short
    // name
    // local
    // variable
    // for
    // readability
    double norm;
    double hx, hy, _2bx, _2bz;
    double s1, s2, s3, s4;
    double qDot1, qDot2, qDot3, qDot4;

    // Auxiliary variables to avoid repeated arithmetic
    double _2q1mx;
    double _2q1my;
    double _2q1mz;
    double _2q2mx;
    double _4bx;
    double _4bz;
    double _2q1 = 2.0 * q1;
    double _2q2 = 2.0 * q2;
    double _2q3 = 2.0 * q3;
    double _2q4 = 2.0 * q4;
    double _2q1q3 = 2.0 * q1 * q3;
    double _2q3q4 = 2.0 * q3 * q4;
    double q1q1 = q1 * q1;
    double q1q2 = q1 * q2;
    double q1q3 = q1 * q3;
    double q1q4 = q1 * q4;
    double q2q2 = q2 * q2;
    double q2q3 = q2 * q3;
    double q2q4 = q2 * q4;
    double q3q3 = q3 * q3;
    double q3q4 = q3 * q4;
    double q4q4 = q4 * q4;

    // Normalise accelerometer measurement
    norm =  sqrt(ax * ax + ay * ay + az * az);
    if (norm == 0.0)
      return; // handle NaN
    norm = 1 / norm; // use reciprocal for division
    ax *= norm;
    ay *= norm;
    az *= norm;

    // Normalise magnetometer measurement
    norm = sqrt(mx * mx + my * my + mz * mz);
    if (norm == 0.0)
      return; // handle NaN
    norm = 1 / norm; // use reciprocal for division
    mx *= norm;
    my *= norm;
    mz *= norm;

    // Reference direction of Earth's magnetic field
    _2q1mx = 2.0 * q1 * mx;
    _2q1my = 2.0 * q1 * my;
    _2q1mz = 2.0* q1 * mz;
    _2q2mx = 2.0 * q2 * mx;
    hx = mx * q1q1 - _2q1my * q4 + _2q1mz * q3 + mx * q2q2 + _2q2 * my * q3
        + _2q2 * mz * q4 - mx * q3q3 - mx * q4q4;
    hy = _2q1mx * q4 + my * q1q1 - _2q1mz * q2 + _2q2mx * q3 - my * q2q2
        + my * q3q3 + _2q3 * mz * q4 - my * q4q4;
    _2bx = sqrt(hx * hx + hy * hy);
    _2bz = -_2q1mx * q3 + _2q1my * q2 + mz * q1q1 + _2q2mx * q4 - mz * q2q2
        + _2q3 * my * q4 - mz * q3q3 + mz * q4q4;
    _4bx = 2.0 * _2bx;
    _4bz = 2.0 * _2bz;

    // Gradient decent algorithm corrective step
    s1 = -_2q3 * (2.0 * q2q4 - _2q1q3 - ax) + _2q2
        * (2.0 * q1q2 + _2q3q4 - ay) - _2bz * q3
        * (_2bx * (0.5 - q3q3 - q4q4) + _2bz * (q2q4 - q1q3) - mx)
        + (-_2bx * q4 + _2bz * q2)
            * (_2bx * (q2q3 - q1q4) + _2bz * (q1q2 + q3q4) - my) + _2bx
        * q3
        * (_2bx * (q1q3 + q2q4) + _2bz * (0.5 - q2q2 - q3q3) - mz);
    s2 = _2q4 * (2.0 * q2q4 - _2q1q3 - ax) + _2q1
        * (2.0 * q1q2 + _2q3q4 - ay) - 4.0 * q2
        * (1 - 2.0 * q2q2 - 2.0 * q3q3 - az) + _2bz * q4
        * (_2bx * (0.5 - q3q3 - q4q4) + _2bz * (q2q4 - q1q3) - mx)
        + (_2bx * q3 + _2bz * q1)
            * (_2bx * (q2q3 - q1q4) + _2bz * (q1q2 + q3q4) - my)
        + (_2bx * q4 - _4bz * q2)
            * (_2bx * (q1q3 + q2q4) + _2bz * (0.5 - q2q2 - q3q3) - mz);
    s3 = -_2q1 * (2.0 * q2q4 - _2q1q3 - ax) + _2q4
        * (2.0 * q1q2 + _2q3q4 - ay) - 4.0 * q3
        * (1 - 2.0 * q2q2 - 2.0 * q3q3 - az) + (-_4bx * q3 - _2bz * q1)
        * (_2bx * (0.5 - q3q3 - q4q4) + _2bz * (q2q4 - q1q3) - mx)
        + (_2bx * q2 + _2bz * q4)
            * (_2bx * (q2q3 - q1q4) + _2bz * (q1q2 + q3q4) - my)
        + (_2bx * q1 - _4bz * q3)
            * (_2bx * (q1q3 + q2q4) + _2bz * (0.5 - q2q2 - q3q3) - mz);
    s4 = _2q2 * (2.0 * q2q4 - _2q1q3 - ax) + _2q3
        * (2.0 * q1q2 + _2q3q4 - ay) + (-_4bx * q4 + _2bz * q2)
        * (_2bx * (0.5 - q3q3 - q4q4) + _2bz * (q2q4 - q1q3) - mx)
        + (-_2bx * q1 + _2bz * q3)
            * (_2bx * (q2q3 - q1q4) + _2bz * (q1q2 + q3q4) - my) + _2bx
        * q2
        * (_2bx * (q1q3 + q2q4) + _2bz * (0.5 - q2q2 - q3q3) - mz);
    norm = 1.0 / sqrt(s1 * s1 + s2 * s2 + s3 * s3 + s4 * s4); // normalise
    // step
    // magnitude
    s1 *= norm;
    s2 *= norm;
    s3 *= norm;
    s4 *= norm;

    // Compute rate of change of quaternion
    qDot1 = 0.5 * (-q2 * gx - q3 * gy - q4 * gz) - beta * s1;
    qDot2 = 0.5 * (q1 * gx + q3 * gz - q4 * gy) - beta * s2;
    qDot3 = 0.5 * (q1 * gy - q2 * gz + q4 * gx) - beta * s3;
    qDot4 = 0.5 * (q1 * gz + q2 * gy - q3 * gx) - beta * s4;

    // Integrate to yield quaternion
    q1 += qDot1 * samplePeriod;
    q2 += qDot2 * samplePeriod;
    q3 += qDot3 * samplePeriod;
    q4 += qDot4 * samplePeriod;
    norm = 1.0 / sqrt(q1 * q1 + q2 * q2 + q3 * q3 + q4 * q4); // normalise
    // quaternion
    quaternion[0] = q1 * norm;
    quaternion[1] = q2 * norm;
    quaternion[2] = q3 * norm;
    quaternion[3] = q4 * norm;
  }

  /**
   * Algorithm IMU update method. Requires only gyroscope and accelerometer
   * data.
   * <p>
   * Optimised for minimal arithmetic. <br>
   * Total ±: 45 <br>
   * Total *: 85 <br>
   * Total /: 3 <br>
   * Total sqrt: 3
   *
   * @param gx
   *            Gyroscope x axis measurement in radians/s.
   * @param gy
   *            Gyroscope y axis measurement in radians/s.
   * @param gz
   *            Gyroscope z axis measurement in radians/s.
   * @param ax
   *            Accelerometer x axis measurement in any calibrated units.
   * @param ay
   *            Accelerometer y axis measurement in any calibrated units.
   * @param az
   *            Accelerometer z axis measurement in any calibrated units.
   */
  List updateGyroAccel(double gx, double gy, double gz, double ax, double ay,
      double az) {
    double q1 = quaternion[0], q2 = quaternion[1], q3 = quaternion[2], q4 = quaternion[3]; // short
    // name
    // local
    // variable
    // for
    // readability
    double norm;
    double s1, s2, s3, s4;
    double qDot1, qDot2, qDot3, qDot4;

    // Auxiliary variables to avoid repeated arithmetic
    double _2q1 = 2.0 * q1;
    double _2q2 = 2.0 * q2;
    double _2q3 = 2.0 * q3;
    double _2q4 = 2.0 * q4;
    double _4q1 = 4.0 * q1;
    double _4q2 = 4.0 * q2;
    double _4q3 = 4.0 * q3;
    double _8q2 = 8.0 * q2;
    double _8q3 = 8.0 * q3;
    double q1q1 = q1 * q1;
    double q2q2 = q2 * q2;
    double q3q3 = q3 * q3;
    double q4q4 = q4 * q4;

    // Normalise accelerometer measurement
    norm = sqrt(ax * ax + ay * ay + az * az);
    if (norm == 0.0)
      return null; // handle NaN
    norm = 1 / norm; // use reciprocal for division
    ax *= norm;
    ay *= norm;
    az *= norm;

    // Gradient decent algorithm corrective step
    s1 = _4q1 * q3q3 + _2q3 * ax + _4q1 * q2q2 - _2q2 * ay;
    s2 = _4q2 * q4q4 - _2q4 * ax + 4.0 * q1q1 * q2 - _2q1 * ay - _4q2 + _8q2
        * q2q2 + _8q2 * q3q3 + _4q2 * az;
    s3 = 4.0 * q1q1 * q3 + _2q1 * ax + _4q3 * q4q4 - _2q4 * ay - _4q3 + _8q3
        * q2q2 + _8q3 * q3q3 + _4q3 * az;
    s4 = 4.0 * q2q2 * q4 - _2q2 * ax + 4.0 * q3q3 * q4 - _2q3 * ay;
    norm = 1.0 / sqrt(s1 * s1 + s2 * s2 + s3 * s3 + s4 * s4); // normalise
    // step
    // magnitude
    s1 *= norm;
    s2 *= norm;
    s3 *= norm;
    s4 *= norm;

    // Compute rate of change of quaternion
    qDot1 = 0.5 * (-q2 * gx - q3 * gy - q4 * gz) - beta * s1;
    qDot2 = 0.5 * (q1 * gx + q3 * gz - q4 * gy) - beta * s2;
    qDot3 = 0.5 * (q1 * gy - q2 * gz + q4 * gx) - beta * s3;
    qDot4 = 0.5 * (q1 * gz + q2 * gy - q3 * gx) - beta * s4;

    // Integrate to yield quaternion
    q1 += qDot1 * samplePeriod;
    q2 += qDot2 * samplePeriod;
    q3 += qDot3 * samplePeriod;
    q4 += qDot4 * samplePeriod;
    norm = 1.0 / sqrt(q1 * q1 + q2 * q2 + q3 * q3 + q4 * q4); // normalise
    // quaternion
    quaternion[0] = q1 * norm;
    quaternion[1] = q2 * norm;
    quaternion[2] = q3 * norm;
    quaternion[3] = q4 * norm;


    ////MyCode

    return quaternion;
  }

}