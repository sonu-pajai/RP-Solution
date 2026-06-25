module ApplicationHelper
  def sort_link(column, label)
    direction = (params[:sort] == column && params[:direction] == "asc") ? "desc" : "asc"
    arrow = if params[:sort] == column
              params[:direction] == "asc" ? " ▲" : " ▼"
            else
              ""
            end
    link_to(raw("#{label}#{arrow}"), request.params.merge(sort: column, direction: direction), style: "color:inherit; text-decoration:none;")
  end
end
