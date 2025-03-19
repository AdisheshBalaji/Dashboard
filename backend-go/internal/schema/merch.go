package schema

import "time"

type Merch struct {
	ID          int       `json:"id"`
	Title       string    `json:"title"`
	Deadline    time.Time `json:"deadline"`
	Price       float64   `json:"price"`
	ImageURL    string    `json:"image_url"`
	Description string    `json:"description"`
	UPIID       string    `json:"upi_id"`
	CreatedAt   time.Time `json:"created_at"`
}

type Order struct {
	ID            int       `json:"id"`
	MerchID       int       `json:"merch_id"`
	UserID        int       `json:"user_id"`
	Size          string    `json:"size"`
	TransactionID string    `json:"transaction_id"`
	DisplayName   string    `json:"display_name"`
	Status        bool      `json:"status"`
	OrderDate     time.Time `json:"order_date"`
}

type OrderResponse struct {
	ID            int       `json:"id"`
	MerchID       int       `json:"merch_id"`
	Title         string    `json:"title"`
	Price         string    `json:"price"`
	ImageURL      string    `json:"image_url"`
	Size          string    `json:"size"`
	Status        bool      `json:"status"`
	OrderDate     time.Time `json:"order_date"`
	TransactionID string    `json:"transaction_id"`
	DisplayName   string    `json:"display_name"`
}