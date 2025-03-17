from backend.backend import queries
from fastapi import Form, HTTPException, Request, APIRouter
from fastapi.responses import JSONResponse
from datetime import datetime
from typing import Optional
import logging
import psycopg2.extras
from pydantic import EmailStr, constr
from utils import conn 

app = APIRouter(
    prefix="/lambdaverse",
)

# Set up logging
logger = logging.getLogger(__name__)

@app.post("/register")
async def register_lambdaverse(
    request: Request,
    name: constr(min_length=1, max_length=255) = Form(...),
    email: EmailStr = Form(...),
    institution: constr(min_length=1, max_length=255) = Form(...),
    role: constr(min_length=1, max_length=50) = Form(...),
    source: Optional[str] = Form(None),
    talks: bool = Form(False),
    hackathon: bool = Form(False),
    workshop: bool = Form(False),
    networking: bool = Form(False)
):
    try:
        # Validate role
        valid_roles = ["student", "professional", "faculty", "other"]
        if role not in valid_roles:
            raise HTTPException(status_code=400, detail=f"Invalid role. Must be one of: {', '.join(valid_roles)}")
        
        # Validate source
        valid_sources = ["social", "friend", "email", "website", "event", "other", None]
        if source not in valid_sources:
            raise HTTPException(status_code=400, detail=f"Invalid source. Must be one of: {', '.join([s for s in valid_sources if s is not None])}, or null")
        
        # Create interests list from checkbox values
        interests = []
        if talks:
            interests.append("Tech Talks & Panels")
        if hackathon:
            interests.append("Hackathon: Code Blitz")
        if workshop:
            interests.append("Workshops")
        if networking:
            interests.append("Networking")
        
        # Get client info for analytics
        client_host = request.client.host if request.client else None
        user_agent = request.headers.get("user-agent", "")

        # Database connection
        cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        try:
            # SQL query using parameterized queries for safety
            query = """
            INSERT INTO lambdaverse_registrations (
                name, 
                email, 
                institution, 
                role, 
                source, 
                interests,
                registration_date,
                user_agent,
                ip_address
            ) 
            VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s
            )
            RETURNING id;
            """
            
            # Execute the query
            cursor.execute(query, (
                name, 
                email, 
                institution, 
                role, 
                source, 
                interests,  # List will be stored as JSON/ARRAY
                datetime.utcnow(),
                user_agent,
                client_host
            ))
            
            registration_id = cursor.fetchone()[0]  # Get the returned ID
            conn.commit()
            
            return JSONResponse(
                status_code=201,
                content={
                    "message": "Successfully registered for LambdaVerse 2025",
                    "registration_id": registration_id,
                    "status": "success"
                }
            )
            
        except psycopg2.errors.UniqueViolation:
            # Handle duplicate email registration
            conn.rollback()
            raise HTTPException(status_code=409, detail="This email is already registered for the event")
            
        except Exception as db_error:
            # Rollback the transaction in case of other errors
            conn.rollback()
            logger.error(f"Database error: {str(db_error)}")
            raise HTTPException(status_code=500, detail="Database error occurred during registration")
        
        finally:
            cursor.close()  # Ensure cursor is closed
        
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
        
    except Exception as e:
        # Log any other errors
        logger.error(f"Registration error: {str(e)}")
        raise HTTPException(status_code=500, detail="An error occurred during registration")
