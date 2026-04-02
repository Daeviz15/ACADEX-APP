import os
import cloudinary
import cloudinary.uploader
import logging
from dotenv import load_dotenv

load_dotenv()
logger = logging.getLogger(__name__)

# Configure Cloudinary
cloudinary.config( 
    cloud_name = os.getenv("CLOUDINARY_CLOUD_NAME"), 
    api_key = os.getenv("CLOUDINARY_API_KEY"), 
    api_secret = os.getenv("CLOUDINARY_API_SECRET"),
    secure=True
)

async def upload_image_to_cloudinary(file_path: str, pub_id: str = None) -> str:
    """
    Uploads a local image file to Cloudinary under the 'acadex/past_questions' folder.
    Returns the secure HTTPS URL.
    """
    try:
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"Local file not found: {file_path}")
            
        options = {"folder": "acadex/past_questions"}
        if pub_id:
            options["public_id"] = pub_id
            
        # Cloudinary's uploader runs synchronously, but since it's a network task
        # we can just run it directly in this script. For proper async environments
        # we could run it in a ThreadPoolExecutor, but this is fine for migration.
        response = cloudinary.uploader.upload(file_path, **options)
        
        secure_url = response.get("secure_url")
        if not secure_url:
            raise ValueError("Cloudinary did not return a secure URL.")
            
        return secure_url
        
    except Exception as e:
        logger.error(f"Cloudinary upload failed for {file_path}: {e}")
        return None
