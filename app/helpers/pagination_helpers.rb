# helpers/pagination_helpers.rb
module PaginationHelpers
  DEFAULT_PER_PAGE = 5

  # Paginate a collection
  def paginate(collection, page: 1, per_page: DEFAULT_PER_PAGE)
    page = [page.to_i, 1].max
    per_page = [per_page.to_i, 1].max

    total_count = collection.count
    total_pages = (total_count.to_f / per_page).ceil
    total_pages = [total_pages, 1].max

    # Ensure current page doesn't exceed total pages
    page = [page, total_pages].min

    offset = (page - 1) * per_page
    records = collection.limit(per_page).offset(offset)

    {
      records: records,
      current_page: page,
      total_pages: total_pages,
      total_count: total_count,
      per_page: per_page,
      has_prev: page > 1,
      has_next: page < total_pages,
      prev_page: (page > 1) ? page - 1 : nil,
      next_page: (page < total_pages) ? page + 1 : nil,
      start_record: (total_count > 0) ? offset + 1 : 0,
      end_record: [offset + per_page, total_count].min
    }
  end

  # Generate pagination HTML
  def pagination_html(pagination, base_url, query_params = {})
    return "" if pagination[:total_pages] <= 1

    html = '<nav class="pagination-container" aria-label="Pagination">'
    html += '<ul class="pagination">'

    # Previous button
    if pagination[:has_prev]
      prev_url = build_pagination_url(base_url, pagination[:prev_page], query_params)
      html += %(<li class="page-item"><a href="#{prev_url}" class="page-link page-prev" aria-label="Previous"><i class="fa-solid fa-chevron-left"></i> Prev</a></li>)
    else
      html += '<li class="page-item disabled"><span class="page-link page-prev"><i class="fa-solid fa-chevron-left"></i> Prev</span></li>'
    end

    # Page numbers
    pages_to_show = calculate_visible_pages(pagination[:current_page], pagination[:total_pages])

    pages_to_show.each do |page_num|
      if page_num == :ellipsis
        html += '<li class="page-item ellipsis"><span class="page-link">...</span></li>'
      elsif page_num == pagination[:current_page]
        html += %(<li class="page-item active"><span class="page-link" aria-current="page">#{page_num}</span></li>)
      else
        page_url = build_pagination_url(base_url, page_num, query_params)
        html += %(<li class="page-item"><a href="#{page_url}" class="page-link">#{page_num}</a></li>)
      end
    end

    # Next button
    if pagination[:has_next]
      next_url = build_pagination_url(base_url, pagination[:next_page], query_params)
      html += %(<li class="page-item"><a href="#{next_url}" class="page-link page-next" aria-label="Next">Next <i class="fa-solid fa-chevron-right"></i></a></li>)
    else
      html += '<li class="page-item disabled"><span class="page-link page-next">Next <i class="fa-solid fa-chevron-right"></i></span></li>'
    end

    html += "</ul>"
    html += "</nav>"

    html
  end

  # Pagination info text
  def pagination_info(pagination)
    return "No records found" if pagination[:total_count] == 0

    "Showing #{pagination[:start_record]} to #{pagination[:end_record]} of #{pagination[:total_count]} records"
  end

  private

  def build_pagination_url(base_url, page, query_params = {})
    params = query_params.merge(page: page)
    query_string = params.map { |k, v| "#{k}=#{v}" }.join("&")
    "#{base_url}?#{query_string}"
  end

  def calculate_visible_pages(current_page, total_pages)
    # Show max 7 page numbers with ellipsis for large page counts
    max_visible = 7

    return (1..total_pages).to_a if total_pages <= max_visible

    pages = []

    if current_page <= 4
      # Near the start: 1 2 3 4 5 ... last
      pages = (1..5).to_a
      pages << :ellipsis
      pages << total_pages
    elsif current_page >= total_pages - 3
      # Near the end: 1 ... last-4 last-3 last-2 last-1 last
      pages << 1
      pages << :ellipsis
      pages += ((total_pages - 4)..total_pages).to_a
    else
      # In the middle: 1 ... curr-1 curr curr+1 ... last
      pages << 1
      pages << :ellipsis
      pages += ((current_page - 1)..(current_page + 1)).to_a
      pages << :ellipsis
      pages << total_pages
    end

    pages
  end
end
