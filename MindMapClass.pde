class MindMap
{
        //MindMap parentNode;
        List<MindMap> childNodes;

        String caption;
        int level;
        String colorStr;
        int colorInt;
        String nodeLink;
        String parentLink;
        //float cw;
       
        int fontSize = 20;
        
        PVector position;
        float radius;
	PVector childAngle;

        boolean bHasChildren = true;
        boolean bHasParent = false;
        boolean bUseDefaultPosition = true;

        MindMap( XML xml, int level )
        {
                position = new PVector( WINDOWCENTER.x, WINDOWCENTER.y );
                radius = 160.0f;
		childAngle = new PVector( random(2*PI), random(2*PI) );
                this.level = level;
                
                /**
                 * All the XML loading work and creations of childNodes are done here
                 * 
                 * The child childNodes are created recursively
                 */
                 
                childNodes = new ArrayList<MindMap>();
                if ( level == 0 ) {
                        activeNodeCaption = caption = xml.getString( "caption" );
                        parentLink = xml.getString("parentLink");
                        nodeLink = xml.getString("linkUrl");
                        colorStr = xml.getString("colour");
                        colorInt = Integer.parseInt(colorStr,16);
                        XML[] children = xml.getChildren( "node" );
                        for ( int n = 0; n < children.length; ++n ) {
                                childNodes.add( new MindMap(children[n], level+1) );
				MindMap node = childNodes.get( childNodes.size()-1 );
                                node.caption = children[n].getString( "caption" );
                                node.nodeLink = children[n].getString( "linkUrl" );
                                node.colorStr = children[n].getString( "colour" );
				node.colorInt = Integer.parseInt( node.colorStr, 16 );
                                node.parentLink = children[n].getString( "parentLink" );
                                
                        }
                } else if ( level > 0 ) {
                  	XML[] children = xml.getChildren( "node" );
                        if ( children.length == 0 ) {
                                bHasChildren = false;
                                return;
                        }

                        for ( int n = 0; n < children.length; ++n ) {
                                childNodes.add( new MindMap(children[n], level+1) );
				MindMap node = childNodes.get( childNodes.size()-1 );
                                node.caption = children[n].getString( "caption" );
                                node.nodeLink = children[n].getString( "linkUrl" );
                                node.colorStr = children[n].getString( "colour" );
				node.colorInt = Integer.parseInt( node.colorStr, 16 );
                      }
                }
        }
        
	void onMousePress( PVector mousePos )
        { 
        	if( caption == activeNodeCaption ) {
                	if( touch(this,mousePos) ){
                		if( level > 0 )
                        	link( parentLink,"_new" );
                	} else {
                        	if ( hasChildren() == true ){
                            		for( int n = 0; n < childNodes.size(); ++n ) {
                                    		MindMap node = childNodes.get( n );
                                        	if ( touch(node, mousePos) )
                                            		if ( !node.hasChildren() )
                                              			link( node.nodeLink,"_new" );
                			}
				}
			}
		}
	}

        
        /**
         * onMouseDragged - triggered when a mouse button is dragged.
         * @mousePos: mouse position when released
         *
         * called by the mouseDragged(). used to move the nodes around.
	 *
         */
        
        void onMouseDragged( PVector mousePos )
        {
                if ( caption == activeNodeCaption  ) {
                        if ( touch(this, mousePos) && level == 0 ) {
                                bUseDefaultPosition = false;
                                setPosition( mousePos.x, mousePos.y );
                        }
                }
        }
        
        /**
         * onMouseRelease - triggered when a mouse button is released.
         * @mousePos: mouse position when released
         *
         * called by the mouseReleased(). used to switch nodes.
         */
        
        void onMouseRelease( PVector mousePos )
        {
                if ( caption == activeNodeCaption  ) {
                        for ( int n = 0; n < childNodes.size(); ++n ) {
                                MindMap node = childNodes.get( n );
                                if ( touch(node, mousePos) ) {
                                        if ( node.hasChildren() ) {
                                                activeMindMap = node;
                                                activeNodeCaption = node.caption;
                                                if ( node.level > 0 ) {
                                                        node.setParent( this );
                                                }
                                        }
                                }
                        }
                }
        }

        /**
         * update - calculate and update the positions of the current node and its children
         */
        
        void update()
        {
         	position.x = constrain( position.x, MIN_X, MAX_X);
         	position.y = constrain( position.y, MIN_Y, MAX_Y);
                
		if ( caption == activeNodeCaption ) {
                        int numChildNodes = childNodes.size();
                        float angleStep = 2*PI/numChildNodes;
                        for ( int n = 0; n < numChildNodes; ++n ) {
                                MindMap node = childNodes.get( n );
                                float angle = n * angleStep;
				node.onChildOf( this, angle );
                        }
                
                        if ( dist(position.x, position.y, WINDOWCENTER.x, WINDOWCENTER.y) > 1.0f )
                                if ( bUseDefaultPosition )
                                        moveTo( WINDOWCENTER );
                }
        }
        
        /**
         * draw - draw the current node and its children to the screen.
         * 
         * all the drawing work is done here. no calculations.
	 *
         */

        void draw()
        {
                if ( caption == activeNodeCaption  ) {
                        if ( bHasChildren ) {
                                for ( int n = 0; n < childNodes.size(); ++n ) {
                                        MindMap node = childNodes.get( n );
                                        stroke(33);
                                        line( position.x, position.y, node.position.x, node.position.y );
                                      
                                        node.draw();
                                }
                        }
                }

                smooth();
                
                fill(red(colorInt),green(colorInt),blue(colorInt));
                stroke(red(colorInt),green(colorInt),blue(colorInt));
                ellipseMode(CENTER);
                ellipse( position.x, position.y, radius, radius );
                //noStroke();
                fill( 255 );
                textSize(fontSize);
                textAlign(CENTER);
                float descent = textDescent();
                text( caption, position.x+descent, position.y+descent ); /* Some magic number for adjusting text position */
        }
        
        /**
         * setParent - assign a node as this node's parent
         */
        
        void setParent( MindMap node )
        {
                if ( !bHasParent ) {
                        childNodes.add( node );
                        bHasParent = true;
                }
        }

        /**
         * setPosition - set the position of the node
         * @x: the x-coordinate of the new position
         * @y: the y-coordinate of the new position
         */
        
        void setPosition( float x, float y )
        {
                position.x = x;
                position.y = y;
        }
        
        /**
         * moveTo - move the node smoothly to new position
         * @loc: a PVector of the new position
         */
        
        void moveTo( PVector loc )
        {
                position.x += ( loc.x - position.x ) / 10.0f;
                position.y += ( loc.y - position.y ) / 10.0f;
        }

	/**
	 * onChildOf - called when 'this' is a child of an active node
	 * @node: the active node
	 * @angle: angle assigned by the active node
	 *	   used for the actual positioning of
	 *	   this child node
	 *
	 */

	void onChildOf( MindMap node, float angle )
	{
		childAngle.x = ( childAngle.x + PI*CHILD_ANGLE_SCALE_X ) % ( 2*PI );
		childAngle.y = ( childAngle.y + PI*CHILD_ANGLE_SCALE_Y ) % ( 2*PI );
                float xPos = node.position.x + DISTANCE * cos(angle) + CHILD_DISTANCE * sin( childAngle.x ) * CHILD_MOVE_SCALE_X;
                float yPos = node.position.y + DISTANCE * sin(angle) + CHILD_DISTANCE * cos( childAngle.y ) * CHILD_MOVE_SCALE_Y;
                moveTo( new PVector(xPos, yPos) );
		
	}
        
        float getX()
        {
                return position.x;
        }
        
        float getY()
        {
                return position.y;
        }
        
        /**
         * touch - check if a PVector is inside the node
         * @node: target node to check
         * @mousePos: the position of the mouse
         *
         * Could use it for purposes other than checking mouse position
         */
        
        boolean touch( MindMap node, PVector mousePos )
        {
                if ( dist(node.getX(), node.getY(), mousePos.x, mousePos.y) < radius )
                        return true;
                return false;
        }
        
        /**
         * hasChildren - checks if the current node has children
         *
         * return true if there's children and false if otherwise
         */
        
        boolean hasChildren()
        {
                return bHasChildren;
        }
}

