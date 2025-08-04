from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import uvicorn
import os
from datetime import datetime

# Initialize FastAPI app
app = FastAPI(
    title="HSBC Pipeline Demo API",
    description="A FastAPI application for HSBC pipeline demonstration",
    version="1.0.0",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Pydantic models
class Item(BaseModel):
    id: Optional[int] = None
    name: str
    description: Optional[str] = None
    price: float
    created_at: Optional[datetime] = None


class HealthCheck(BaseModel):
    status: str
    timestamp: datetime
    version: str


# In-memory storage (replace with database in production)
items_db = []
item_id_counter = 1


@app.get("/", response_model=dict)
def read_root():
    """Root endpoint returning API information"""
    return {
        "message": "Welcome to HSBC Pipeline Demo API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health",
    }


@app.get("/health", response_model=HealthCheck)
def health_check():
    """Health check endpoint"""
    return HealthCheck(status="healthy", timestamp=datetime.now(), version="1.0.0")


@app.get("/items", response_model=List[Item])
def get_items():
    """Get all items"""
    return items_db


@app.get("/items/{item_id}", response_model=Item)
def get_item(item_id: int):
    """Get a specific item by ID"""
    for item in items_db:
        if item.id == item_id:
            return item
    raise HTTPException(status_code=404, detail="Item not found")


@app.post("/items", response_model=Item)
def create_item(item: Item):
    """Create a new item"""
    global item_id_counter
    item.id = item_id_counter
    item.created_at = datetime.now()
    item_id_counter += 1
    items_db.append(item)
    return item


@app.put("/items/{item_id}", response_model=Item)
def update_item(item_id: int, item: Item):
    """Update an existing item"""
    for i, existing_item in enumerate(items_db):
        if existing_item.id == item_id:
            item.id = item_id
            item.created_at = existing_item.created_at
            items_db[i] = item
            return item
    raise HTTPException(status_code=404, detail="Item not found")


@app.delete("/items/{item_id}")
def delete_item(item_id: int):
    """Delete an item"""
    for i, item in enumerate(items_db):
        if item.id == item_id:
            deleted_item = items_db.pop(i)
            return {"message": f"Item {item_id} deleted successfully"}
    raise HTTPException(status_code=404, detail="Item not found")


@app.get("/info")
def get_info():
    """Get application information"""
    return {
        "app_name": "HSBC Pipeline Demo",
        "environment": os.getenv("ENVIRONMENT", "development"),
        "deployment_time": os.getenv("DEPLOYMENT_TIME", "unknown"),
        "build_number": os.getenv("BUILD_NUMBER", "unknown"),
    }


if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    host = os.getenv("HOST", "0.0.0.0")
    uvicorn.run(app, host=host, port=port)
