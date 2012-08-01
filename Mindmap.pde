final int WIDTH = 800;
final int HEIGHT = 600;
final int MIN_X = 0;
final int MAX_X = 800;
final int MIN_Y = 0;
final int MAX_Y = 800;
final PVector TOPLEFT = new PVector( 100, 100 );
final PVector BOTTOMRIGHT = new PVector( 700, 500 );

final float distance = 256.0f;
final PVector center = new PVector( WIDTH/2.0f, HEIGHT/2.0f );

String activeNodeCaption;
String nodeLink;

XML xml;
MindMap mindMap;
MindMap activeMindMap;

void setup()
{
        size( WIDTH, HEIGHT );
        smooth();
        
        xml = loadXML( "mindmap.xml" );
        mindMap = new MindMap( xml, 0 );
        activeMindMap = mindMap;
}

void draw()
{
        background( 255,250,250 );
        activeMindMap.update();
        activeMindMap.draw();
}

void mouseDragged()
{
        activeMindMap.onMouseDragged( new PVector(mouseX, mouseY) );
}

void mouseReleased()
{
        activeMindMap.onMouseRelease( new PVector(mouseX, mouseY) );
}

void mousePressed()
{
        activeMindMap.onMousePress(new PVector(mouseX,mouseY));
}
