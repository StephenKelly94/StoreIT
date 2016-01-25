json.id @folder.id
json.dirty_flag @folder.dirty_flag
json.name @folder.name
json.folder_path @folder.folder_path
json.parent @parent
json.user_files @user_files
json.children @folders, :id, :name, :folder_path