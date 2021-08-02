# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'csv'
require 'securerandom'
enable :method_override

# メモ一覧の表示
get '/notes' do
  @data_list = CSV.read('data.csv', headers: true)
  erb :index
end

# 新規メモ作成ページの表示
get '/notes/new' do
  erb :new
end

# 新規メモを投稿
post '/notes' do
  id = SecureRandom.uuid
  CSV.open('data.csv', 'a') do |csv|
    csv << [id, params[:title], params[:content]]
  end
  redirect to('/notes')
end

# メモ詳細の表示
get '/notes/:id' do
  csv_table = CSV.table('data.csv', headers: true).by_row
  @data = csv_table.find { |row| row[:id] == params[:id] }
  if @data.nil?
    erb :error404
  else
    erb :show
  end
end

# メモを削除
delete '/notes/:id' do
  csv_table = CSV.table('data.csv', headers: true).by_row
  csv_table.delete_if { |row| row[:id] == params[:id] }

  CSV.open('data.csv', 'w', headers: true) do |csv|
    csv << %w[id title content]
    csv_table.each { |row| csv << row }
  end
  redirect to('/notes')
end

# メモの編集ページを表示
get '/notes/:id/edit' do
  csv_table = CSV.table('data.csv', headers: true).by_row
  @data = csv_table.find { |row| row[:id] == params[:id] }
  if @data.nil?
    erb :error404
  else
    erb :edit
  end
end

# メモの更新
patch '/notes/:id' do
  csv_table = CSV.table('data.csv', headers: true)
  csv_table.each do |row|
    if row[:id] == params[:id]
      row[:title] = params[:title]
      row[:content] = params[:content]
    end
  end
  CSV.open('data.csv', 'w', headers: true) do |csv|
    csv << %w[id title content]
    csv_table.each { |row| csv << row }
  end
  redirect to('/notes')
end

not_found do
  erb :error404
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
