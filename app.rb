# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'csv'
require 'securerandom'
require 'pg'
enable :method_override

# メモ一覧の表示
get '/notes' do
  @conn = PG.connect(dbname: 'sinatra_note_app')
  erb :index
end

# 新規メモ作成ページの表示
get '/notes/new' do
  erb :new
end

# 新規メモを投稿
post '/notes' do
  conn = PG.connect(dbname: 'sinatra_note_app')
  conn.exec( "INSERT INTO notes (title,content) VALUES ('#{params[:title]}','#{params[:content]}')")
  redirect to('/notes')
end

# メモ詳細の表示
get '/notes/:id' do
  conn = PG.connect(dbname: 'sinatra_note_app')
  conn.exec("SELECT * FROM notes WHERE id = #{params[:id]}").each do |result|
    @data = result
  end
  if @data.nil?
    erb :error404
  else
    erb :show
  end
end

# メモを削除
delete '/notes/:id' do
  conn = PG.connect(dbname: 'sinatra_note_app')
  conn.exec("DELETE FROM notes WHERE id = #{params[:id]}")
  redirect to('/notes')
end

# メモの編集ページを表示
get '/notes/:id/edit' do
  conn = PG.connect(dbname: 'sinatra_note_app')
  conn.exec("SELECT * FROM notes WHERE id = #{params[:id]}").each do |result|
    @data = result
  end
  if @data.nil?
    erb :error404
  else
    erb :edit
  end
end

# メモの更新
patch '/notes/:id' do
  conn = PG.connect(dbname: 'sinatra_note_app')
  conn.exec( "UPDATE notes SET title = '#{params[:title]}', content = '#{params[:content]}' WHERE id = #{params[:id]}")
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
