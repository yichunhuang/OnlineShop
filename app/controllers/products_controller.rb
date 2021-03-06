class ProductsController < ApplicationController
	before_action :redirect_to_root_if_not_log_in, except: [:index, :show, :products]
	before_action :prepare_index, only: [:index, :products, :show]
	before_action :get_products, only: [:index]
	before_action :create_pagination, only: [:index]

	LIMITED_PRODUCTS_NUMBER = 20

	def index
	end

	def show
		@product = Product.find_by_id(params[:id])
	end

	def new

		@product = Product.new
	end

	def create
		image = params[:product][:image]
		if image
			#用save_file把圖片存到指定的路徑之後，再將指定的路徑和其他參數合起來create product
			image_url = save_file(image)
		end

		product = Product.create(product_permit.merge({image_url: image_url}))

		flash[:notice] = "Create Success!"
		redirect_to action: :new
	end

	def edit
		@product = Product.find_by_id(params[:id]) #find_by_id 會return nil，find會直接當掉
		if @product.blank?
			redirect_to root_path
			return #不return會繼續往下做
		end
	end

	def update
		product = Product.find(params[:id])

		image = params[:product][:image]
		if image
			image_url = save_file(image)
			product.update(product_permit.merge({image_url: image_url}))
		else
			product.update(product_permit)
		end

		

		flash[:notice] = "Edit Success!"
		redirect_to action: :edit
	end

	def destroy
		product = Product.find(params[:id])

		product.destroy

		redirect_to action: :index
	end

	private

	def product_permit
		params.require(:product).permit([:name, :description, :price, :subcategory_id])
	end

	def redirect_to_root_if_not_log_in 
		if !current_user || !current_user.is_admin
			flash[:notice] = "您沒有權限"
			redirect_to root_path
			return
		end
	end

	def save_file(newFile)
		dir_url = Rails.root.join('public', 'uploads/products')

		FileUtils.mkdir_p(dir_url) unless File.directory?(dir_url)

		file_url = dir_url + newFile.original_filename

		File.open(file_url, 'w+b') do |file|
			file.write(newFile.read)
		end

		return "/uploads/products/" + newFile.original_filename
	end

	def prepare_index
		create_ad
		get_current_page
		get_all_categories
	end

	def create_ad
		@ad = {
			title: "廣告標題",
			description: "廣告內容",
			action_title: "閱讀更多"
		}
	end

	def get_current_page
		if params[:page]
			@page = params[:page].to_i 
		else
			@page = 1
		end
	end

	def get_all_categories
		@categories = Category.includes(:subcategories).all
	end

	def get_products
		# model的關聯性要先做出來(has_one, belongs_to, ..)才能做include增加SQL效率
		@products = Product.includes(:subcategory).includes(:category).all
	end

	def create_pagination
		@first_page = 1
		count = @products.count
		@last_page = count / LIMITED_PRODUCTS_NUMBER
		if (count % LIMITED_PRODUCTS_NUMBER)
			@last_page += 1
		end

		@products = @products.offset((@page - 1) * LIMITED_PRODUCTS_NUMBER).limit(LIMITED_PRODUCTS_NUMBER)
	
	end

end
