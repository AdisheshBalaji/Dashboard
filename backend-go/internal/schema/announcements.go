package schema

import "mime/multipart"

type Announcement struct {
	ID          int      `json:"id"`
	Title       string   `json:"title"`
	Description string   `json:"description"`
	CreatedAt   int      `json:"createdAt"`
	CreatedBy   string   `json:"createdBy"`
	Tags        []string `json:"tags"`
	Category    []string `json:"category"`
}

type AnnouncementWithImages struct {
	Announcement
	ImageURI string `json:"imageURI"`
}

type AnnouncementRequest struct {
	Title       string                `form:"title"`
	Description string                `form:"description"`
	CreatedAt   int64                 `form:"createdAt"`
	CreatedBy   string                `form:"createdBy"`
	Tags        []string              `form:"tags"`
	Category    []string              `form:"category"`
	Image       *multipart.FileHeader `form:"image"`
}
