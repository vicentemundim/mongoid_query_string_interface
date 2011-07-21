module Mongoid
  module Paginate
    def paginate(options={})
      per_page = (options[:per_page] || 20).to_i
      page = (options[:page] || 1).to_i
      offset = (page - 1) * per_page

      WillPaginate::Collection.create(page, per_page, count) do |pager|
        pager.replace(skip(offset).limit(per_page).to_a)
      end
    end
  end
end