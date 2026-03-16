import processing.serial.*;
import java.awt.event.KeyEvent;
import java.io.IOException;

Serial myPort;

String angle = "";
String distance = "";
String data = "";
String noObject;
float pixsDistance;
int iAngle = 0; // Initialize to 0 so the line starts at 0 degrees
int iDistance = 0;
int index1 = 0;
int index2 = 0;

// Calculate the maximum radius based on your radar's size
// This is the radius of the largest arc drawn in drawRadar()
float maxRadius;
float radarCenterY;

void settings() {
    size(1200, 700);
}

void setup() {
    smooth();
    surface.setResizable(true);

    // Calculate maxRadius and radarCenterY based on current screen size
    maxRadius = (width - width * 0.0625) / 2;
    radarCenterY = height - height * 0.074;

    // Use the correct COM port for your Arduino (Change "COM5" if needed)
    // NOTE: This will fail if the port is not available.
    try {
        myPort = new Serial(this, "COM5", 9600);
        myPort.bufferUntil('.');
    } catch (Exception e) {
        println("Could not open serial port. Check if Arduino is connected to COM5.");
    }
}

void draw() {
    // Clear background partially for a trailing effect
    fill(0, 4);
    rect(0, 0, width, height - height * 0.065);

    fill(98, 245, 31);
    noStroke();

    // Recalculate based on current size in case of window resize
    maxRadius = (width - width * 0.0625) / 2;
    radarCenterY = height - height * 0.074;

    drawRadar();
    drawLine();
    drawObject();
    drawText();
}

void serialEvent(Serial myPort) {
    // Check if myPort is null (if serial port failed to open)
    if (myPort == null) return;

    data = myPort.readStringUntil('.');
    if (data == null) return;

    // Remove the delimiter
    data = data.substring(0, data.length() - 1);

    // Split the data string "angle,distance"
    index1 = data.indexOf(",");
    if (index1 > 0 && index1 < data.length() - 1) {
        angle = data.substring(0, index1).trim();
        distance = data.substring(index1 + 1).trim();

        // Convert to int
        iAngle = int(angle);
        iDistance = int(distance);
    }
}

void drawRadar() {
    pushMatrix();
    translate(width / 2, radarCenterY); // Radar center (Origin)

    noFill();
    strokeWeight(2);
    stroke(98, 245, 31);

    // Your existing arcs (distance rings)
    arc(0, 0, (width - width * 0.0625), (width - width * 0.0625), PI, TWO_PI);
    arc(0, 0, (width - width * 0.27), (width - width * 0.27), PI, TWO_PI);
    arc(0, 0, (width - width * 0.479), (width - width * 0.479), PI, TWO_PI);
    arc(0, 0, (width - width * 0.687), (width - width * 0.687), PI, TWO_PI);

    // Radial lines
    line(-width / 2, 0, width / 2, 0); // 180° to 0° baseline
    for (int a = 30; a <= 150; a += 30) {
        float x = maxRadius * cos(radians(a));
        float y = -maxRadius * sin(radians(a)); // Negative y for top semi-circle
        line(0, 0, x, y);
    }

    popMatrix();
}

void drawLine() {
    pushMatrix();
    translate(width / 2, radarCenterY);

    strokeWeight(4);
    stroke(255, 0, 0); // Red sweep line

    // Calculate the end point of the sweep line based on the current angle (iAngle)
    float x_end = maxRadius * cos(radians(iAngle));
    float y_end = -maxRadius * sin(radians(iAngle));

    // Draw line from center (0,0) to the calculated end point
    line(0, 0, x_end, y_end);

    popMatrix();
}

void drawObject() {
    // Map the distance (0-40cm) to screen pixels (0-maxRadius)
    // Assuming 40cm is the max range shown on the radar
    // Note: The conversion constant (maxRadius / 40.0) is more reliable than your existing complex calculation.
    pixsDistance = map(iDistance, 0, 40, 0, maxRadius);

    pushMatrix();
    translate(width / 2, radarCenterY);
    strokeWeight(12); // Dot size
    fill(255, 0, 0); // Red dot

    // Calculate object position using polar coordinates (r, theta)
    float x_obj = pixsDistance * cos(radians(iAngle));
    float y_obj = -pixsDistance * sin(radians(iAngle));

    // Check if distance is within the 40cm range and draw the red circle/dot
    if (iDistance > 0 && iDistance <= 40) {
        ellipse(x_obj, y_obj, 10, 10); // Draw a small circle/dot for the object
    }

    popMatrix();
}

void drawText() {
    pushMatrix();

    // Draw the black bar at the bottom
    fill(0, 0, 0);
    noStroke();
    rect(0, height - height * 0.0648, width, height);

    fill(98, 245, 31);
    textSize(25);

    // Distance labels (10cm, 20cm, 30cm, 40cm)
    text("10cm", width / 2 + maxRadius * 0.25, radarCenterY + 20);
    text("20cm", width / 2 + maxRadius * 0.50, radarCenterY + 20);
    text("30cm", width / 2 + maxRadius * 0.75, radarCenterY + 20);
    text("40cm", width / 2 + maxRadius * 1.00 - 40, radarCenterY + 20); // Minor adjustment

    textSize(40);
    // Project/Team Text
    text("Team Circuit Breakers ", width - width * 0.875, height - height * 0.0277);

    // Angle and Distance Display
    text("Angle: " + iAngle + " °", width - width * 0.48, height - height * 0.0277);
    text("Distance: ", width - width * 0.26, height - height * 0.0277);

    if (iDistance > 0 && iDistance <= 300) {
        text(" " + iDistance + " cm", width - width * 0.165, height - height * 0.0277);
    } else {
        // Display "Out of Range" or similar if needed
        text("Out of Range", width - width * 0.165, height - height * 0.0277);
    }

    // Angle text labels (30°, 60°, 90°, etc.)
    textSize(25);
    fill(98, 245, 60);
    for (int a = 30; a <= 150; a += 30) {
        float x = width / 2 + (maxRadius + 30) * cos(radians(a)); // +30 to move text slightly outside the arc
        float y = radarCenterY - (maxRadius + 30) * sin(radians(a));
        // Simple text without rotation, or you can add back rotation if you prefer
        text(a + "°", x - 20, y);
    }

    popMatrix();
}
