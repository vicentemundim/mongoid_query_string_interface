module Mongoid
  module Paginate
    def paginate(options={})
      per_page = (options[:per_page] || 20).to_i
      page = (options[:page] || 1).to_i
      offset = (page - 1) * per_page

      create_paginatable_collection(skip(offset).limit(per_page).to_a, count, page, per_page)
    end

    protected

      def create_paginatable_collection(collection, total, page, per_page)
        WillPaginate::Collection.create(page, per_page, total) do |pager|
          pager.replace(collection)
        end
      end
  end
end