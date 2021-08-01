require 'sinatra'
require 'sinatra/reloader'
require 'csv'
require 'securerandom'
require 'pg'
enable :method_override

# メモ一覧の表示
get '/lists' do
  @data_list = CSV.read("data.csv", headers: true)
  erb :index
end

# 新規メモ作成ページの表示
get '/notes' do
  @id = SecureRandom.uuid
  erb :new
end

# 新規メモを投稿
post '/notes/:id' do
  CSV.open('data.csv','a') do |csv|
    csv << [params[:id], params[:title], params[:content]]
  end
  redirect to('/lists')
end

# メモ詳細の表示
get '/notes/:id' do
  csv_table = CSV.table("data.csv", headers: true).by_row
  @data = csv_table.find { |row| row[:id] == params[:id] }
  erb :show
end

# メモを削除
delete '/notes/:id' do
  csv_table = CSV.table("data.csv", headers: true).by_row
  csv_table.delete_if { |row| row[:id] == params[:id] }

  CSV.open("data.csv", "w", headers: true) do |csv|
    csv << ["id","title","content"]
    csv_table.each { |row| csv << row }
  end
  redirect to('/lists')
  erb :delete
end

# メモの編集ページを表示
get '/notes/:id/edit' do
  csv_table = CSV.table("data.csv", headers: true).by_row
  @data = csv_table.find { |row| row[:id] == params[:id] }
  erb :edit
end

# メモの更新
patch '/notes/:id' do
  csv_table = CSV.table("data.csv", headers: true)
  csv_table.each do |row|
    if row[:id] == params[:id]
      row[:title] = params[:title]
      row[:content] = params[:content]
    end
  end
  CSV.open("data.csv", "w", headers: true) do |csv|
    csv << ["id","title","content"]
    csv_table.each { |row| csv << row }
  end
  redirect to('/lists')
end

not_found do
  erb :error_404
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
