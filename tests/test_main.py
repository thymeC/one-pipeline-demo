import pytest
from fastapi.testclient import TestClient
import sys
import os

# Add the parent directory to the path to import main.py
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app

client = TestClient(app)


def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "version" in data


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "timestamp" in data
    assert data["version"] == "1.0.0"


def test_get_items_empty():
    response = client.get("/items")
    assert response.status_code == 200
    assert response.json() == []


def test_create_item():
    item_data = {"name": "Test Item", "description": "A test item", "price": 29.99}
    response = client.post("/items", json=item_data)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == item_data["name"]
    assert data["price"] == item_data["price"]
    assert data["id"] is not None


def test_get_item():
    # First create an item
    item_data = {
        "name": "Test Item 2",
        "description": "Another test item",
        "price": 19.99,
    }
    create_response = client.post("/items", json=item_data)
    item_id = create_response.json()["id"]

    # Then get the item
    response = client.get(f"/items/{item_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == item_id
    assert data["name"] == item_data["name"]


def test_get_item_not_found():
    response = client.get("/items/999")
    assert response.status_code == 404


def test_update_item():
    # First create an item
    item_data = {
        "name": "Original Item",
        "description": "Original description",
        "price": 10.00,
    }
    create_response = client.post("/items", json=item_data)
    item_id = create_response.json()["id"]

    # Then update it
    update_data = {
        "name": "Updated Item",
        "description": "Updated description",
        "price": 15.00,
    }
    response = client.put(f"/items/{item_id}", json=update_data)
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == update_data["name"]
    assert data["price"] == update_data["price"]


def test_delete_item():
    # First create an item
    item_data = {
        "name": "Item to Delete",
        "description": "This will be deleted",
        "price": 5.00,
    }
    create_response = client.post("/items", json=item_data)
    item_id = create_response.json()["id"]

    # Then delete it
    response = client.delete(f"/items/{item_id}")
    assert response.status_code == 200

    # Verify it's deleted
    get_response = client.get(f"/items/{item_id}")
    assert get_response.status_code == 404


def test_info_endpoint():
    response = client.get("/info")
    assert response.status_code == 200
    data = response.json()
    assert "app_name" in data
    assert "environment" in data
