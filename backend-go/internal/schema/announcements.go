package schema

import "mime/multipart"

type Announcement struct {
	ID          int      `json:"id"`
	Title       string   `json:"title"`
	Description string   `json:"description"`
	CreatedAt   int      `json:"createdAt"`
	CreatedBy   string   `json:"createdBy"`
	Tags        []string `json:"tags"`
}

type AnnouncementWithImages struct {
	Announcement
	ImageUrl string `json:"imageUrl"`
}

type RequestAnnouncement struct {
	Title       string                `form:"title"`
	Description string                `form:"description"`
	CreatedAt   int64                 `form:"createdAt"`
	CreatedBy   string                `form:"createdBy"`
	Tags        []string              `form:"tags"`
	Image       *multipart.FileHeader `form:"image"`
}
