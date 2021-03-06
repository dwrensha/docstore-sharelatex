{db, ObjectId} = require "./mongojs"

module.exports = MongoManager =

	findDoc: (doc_id, callback = (error, doc) ->) ->
		db.docs.find _id: ObjectId(doc_id.toString()), {}, (error, docs = []) ->
			callback error, docs[0]

	getProjectsDocs: (project_id, callback)->
		db.docs.find project_id: ObjectId(project_id.toString()), {}, callback

	getArchivedProjectDocs: (project_id, callback)->
		query =
			project_id: ObjectId(project_id.toString())
			inS3: true
		db.docs.find query, {}, callback

	upsertIntoDocCollection: (project_id, doc_id, lines, callback)->
		update =
			$set:{}
			$inc:{}
			$unset:{}
		update.$set["lines"] = lines
		update.$set["project_id"] = ObjectId(project_id)
		update.$inc["rev"] = 1 #on new docs being created this will set the rev to 1
		update.$unset["inS3"] = true
		db.docs.update _id: ObjectId(doc_id), update, {upsert: true}, callback


	markDocAsDeleted: (doc_id, callback)->
		update =
			$set: {}
		update.$set["deleted"] = true
		db.docs.update _id: ObjectId(doc_id), update, (err)->
			callback(err)

	markDocAsArchived: (doc_id, rev, callback)->
		update =
			$set: {}
			$unset: {}
		update.$set["inS3"] = true
		update.$unset["lines"] = true
		query =
			_id: doc_id
			rev: rev
		db.docs.update query, update, (err)->
			callback(err)