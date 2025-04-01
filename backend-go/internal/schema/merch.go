package schema

import "time"

type MerchSize struct {
	ID        int       `json:"id"`
	MerchID   int       `json:"merch_id"`
	SizeName  string    `json:"name"`
	CreatedAt time.Time `json:"created_at"`
}

type MerchImage struct {
	ID        int       `json:"id"`
	MerchID   int       `json:"merch_id"`
	ImageURL  string    `json:"url"`
	CreatedAt time.Time `json:"created_at"`
}

type Merch struct {
	ID             int          `json:"id"`
	Title          string       `json:"title"`
	Deadline       time.Time    `json:"deadline"`
	Price          float64      `json:"price"`
	ImageURL       string       `json:"image_url"`
	Images         []MerchImage `json:"images"`
	Description    string       `json:"description"`
	UPIID          string       `json:"upi_id"`
	IsOversized    bool         `json:"is_oversized"`
	SizeGuideURL   string       `json:"size_guide_url,omitempty"`
	AvailableSizes []MerchSize  `json:"available_sizes,omitempty"`
	HasSizes       bool         `json:"has_sizes"`
	CreatedAt      time.Time    `json:"created_at"`
}

type Order struct {
	ID            int       `json:"id"`
	MerchID       int       `json:"merch_id"`
	UserID        int       `json:"user_id"`
	Size          *string   `json:"size,omitempty"`
	TransactionID string    `json:"transaction_id"`
	DisplayName   string    `json:"display_name"`
	Status        bool      `json:"status"`
	IsOversized   bool      `json:"is_oversized"`
	OrderDate     time.Time `json:"order_date"`
}

type OrderResponse struct {
	ID            int       `json:"id"`
	MerchID       int       `json:"merch_id"`
	Title         string    `json:"title"`
	Price         string    `json:"price"`
	ImageURL      string    `json:"image_url"`
	Size          *string   `json:"size,omitempty"`
	Status        bool      `json:"status"`
	IsOversized   bool      `json:"is_oversized"`
	OrderDate     time.Time `json:"order_date"`
	TransactionID string    `json:"transaction_id"`
	DisplayName   string    `json:"display_name"`
}
