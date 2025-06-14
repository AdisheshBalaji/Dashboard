from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from Routes.Auth.cookie import get_user_id
from pydantic import BaseModel
from utils import conn
from queries.merch import *
from Routes.User.user import get_user

router = APIRouter(
    prefix="/merch",
    tags=["merch"],
)

class OrderCreate(BaseModel):
    merch_id: int
    size: Optional[str] = None
    display_name: str
    transaction_id: str
    is_oversized: bool

class OrderUpdate(BaseModel):
    status: bool

class StockUpdate(BaseModel):
    quantity: int

@router.get("/items")
def get_items():
    try:
        query = get_all_merch_items()
        cursor = conn.cursor()
        cursor.execute(query)
        items = cursor.fetchall()
        
        images_query = get_merch_images()
        cursor.execute(images_query)
        all_images = cursor.fetchall()
        images_by_merch_id = {}
        for image in all_images:
            merch_id, image_url = image
            if merch_id not in images_by_merch_id:
                images_by_merch_id[merch_id] = []
            images_by_merch_id[merch_id].append({
                "url": image_url
            })
        
        sizes_query = get_merch_sizes()
        cursor.execute(sizes_query)
        all_sizes = cursor.fetchall()
        sizes_by_merch_id = {}
        for size in all_sizes:
            merch_id, size_id, size_name, _ = size
            if merch_id not in sizes_by_merch_id:
                sizes_by_merch_id[merch_id] = []
            sizes_by_merch_id[merch_id].append({
                "id": size_id,
                "name": size_name
            })
        
        result = []
        for item in items:
            merch_id = item[0]
            images = images_by_merch_id.get(merch_id, [])
            sizes = sizes_by_merch_id.get(merch_id, [])
            
            has_sizes = len(sizes) > 0
            
            result.append({
                "id": merch_id,
                "title": item[1],
                "deadline": item[2].isoformat(),
                "price": str(item[3]),
                "image_url": item[4],
                "images": images,
                "description": item[5],
                "upi_id": item[6],
                "created_at": item[7].isoformat(),
                "is_oversized": item[8],
                "size_guide_url": item[9],
                "available_sizes": sizes,
                "has_sizes": has_sizes
            })
        return result
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch merchandise items: {str(e)}"
        )

@router.get("/items/{item_id}")
def get_item(item_id: int):
    try:
        query = get_merch_item(item_id)
        cursor = conn.cursor()
        cursor.execute(query)
        item = cursor.fetchone()
        
        if not item:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Merchandise item with ID {item_id} not found"
            )
            
        images_query = get_merch_images(item_id)
        cursor.execute(images_query)
        images = [{"url": img[1]} for img in cursor.fetchall()]
        
        sizes_query = get_merch_sizes(item_id)
        cursor.execute(sizes_query)
        sizes_data = cursor.fetchall()
        sizes = []
        for size in sizes_data:
            merch_id, size_id, size_name, _ = size
            sizes.append({
                "id": size_id,
                "name": size_name
            })
        
        return {
            "id": item[0],
            "title": item[1],
            "deadline": item[2].isoformat(),
            "price": str(item[3]),
            "image_url": item[4],
            "images": images,
            "description": item[5],
            "upi_id": item[6],
            "created_at": item[7].isoformat(),
            "is_oversized": item[8],
            "size_guide_url": item[9],
            "available_sizes": sizes
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch merchandise item: {str(e)}"
        )

@router.post("/order")
def create_order(order: OrderCreate, user_id: int = Depends(get_user_id)):
    try:
        user = get_user(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        deadline_query = check_deadline_availability(order.merch_id)
        cursor = conn.cursor()
        cursor.execute(deadline_query)
        is_available = cursor.fetchone()[0]
        
        if not is_available:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Order deadline has passed"
            )
        
        item_query = get_merch_item(order.merch_id)
        cursor.execute(item_query)
        item_data = cursor.fetchone()
        
        if not item_data:
            raise HTTPException(status_code=404, detail="Merchandise item not found")
        
        oversized_option = bool(item_data[8])
        
        if order.is_oversized and not oversized_option:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This merchandise does not have an oversized option"
            )
            
        sizes_query = get_merch_sizes(order.merch_id)
        cursor.execute(sizes_query)
        available_sizes = [size[2] for size in cursor.fetchall()]
        has_sizes = len(available_sizes) > 0
        
        if has_sizes:
            if order.size is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Size is required for this merchandise"
                )
            if order.size not in available_sizes:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid size. Must be one of: {', '.join(available_sizes)}"
                )
        elif order.size is not None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This merchandise does not have size options"
            )
        
        chosen_is_oversized = order.is_oversized
        
        order_query = insert_order_query(
            user_id, order.merch_id, order.size,
            order.transaction_id, order.display_name, chosen_is_oversized
        )
        cursor.execute(order_query)
        order_id = cursor.fetchone()[0]
        conn.commit()
        
        return {
            "message": "Order created successfully", 
            "order_id": order_id, 
            "transaction_id": order.transaction_id,
            "payment_status": "completed"
        }
    except HTTPException:
        conn.rollback()
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create order: {str(e)}"
        )

@router.get("/orders")
def list_user_orders(user_id: int = Depends(get_user_id)):
    try:
        user = get_user(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        query = get_user_orders(user_id)
        cursor = conn.cursor()
        cursor.execute(query)
        order_rows = cursor.fetchall()
        
        result = []
        for order in order_rows:
            result.append({
                "id": order[0],
                "merch_id": order[1],
                "title": order[2],
                "price": str(order[3]),
                "image_url": order[4],
                "size": order[5],
                "status": order[6],
                "order_date": order[7].isoformat(),
                "transaction_id": order[8],
                "display_name": order[9],
                "is_oversized": order[10]
            })
        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch user orders: {str(e)}"
        )