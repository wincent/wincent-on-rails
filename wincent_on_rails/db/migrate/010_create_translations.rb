class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.integer     :locale_id
      t.string      :key,         :null => false
      t.string      :translation, :null => false
      t.timestamps
    end

    # database-level constraint to ensure uniqueness of a key within its locale (validates_uniqueness_of vulnerable to races)
    add_index     :translations, [:locale_id, :key], :unique => true
    # TODO: test this and others like it (simulate race)
    # TODO: more of this kind of db-level integrity enforcement (don't trust Rails validations)

    # set up base Spanish translations
    # TODO: potentially consider splitting these out into a Yaml file for easier editing
    Locale.find_by_code('es-ES').translate do |es|

      # db/migrate/xxx_create_locales.rb
      es.learn  'US English',                         'inglés (Estados Unidos)'
      es.learn  'Spanish (Spain)',                    'español (España)'

      # app/controllers/application.rb
      es.learn  'Requested %s not found',             'No se ha encontrado el %s pedido' # BUG: gender concordance can fail here

      # app/controllers/comments_controller.rb
      es.learn  'comment',                            'comentario'

      # app/controllers/emails_controller.rb
      es.learn  'email',                              'dirección de correo'

      # app/controllers/issues_controller.rb
      es.learn  'issue',                              'ficha'

      # app/controllers/locales_controller.rb
      es.learn  'locale',                             'locale'

      # app/controllers/sessions_controller.rb
      es.learn  'session',                            'sesión'
      es.learn  'Successfully logged in.',            'Sesión iniciada con éxito.'
      es.learn  'Invalid login or passphrase.',       'Nombre de usuario o contraseña no válido.'
      es.learn  'You have logged out successfully.',  'Sesión cerrada con éxito.'
      es.learn  "Can't log out (weren't logged in).", 'No se ha podido cerrar la sesión (sesión no estaba iniciada).'

      # app/controllers/statuses_controller.rb
      es.learn  'status',                             'estado'

      # app/controllers/taggings_controller.rb
      es.learn  'tagging',                            'etiquetaje'

      # app/controllers/tags_controller.rb
      es.learn  'tag',                                'etiqueta'

      # app/controllers/translations_controller.rb
      es.learn  'translation',                        'traducción'

      # app/controllers/users_controller.rb
      es.learn  'user',                               'usuario'

      # app/helpers/application_helper.rb
      es.learn  'Created %s',                         'Creado %s'
      es.learn  'Created %s, updated %s',             'Creado %s, modificado %s'

      # lib/additions/time.rb
      es.learn  'in the future',                      'en el futuro'
      es.learn  'now',                                'ahora'
      es.learn  'a few seconds ago',                  'hace unos segundos'
      es.learn  'a minute ago',                       'hace un minuto'
      es.learn  'a couple of minutes ago',            'hace un par de minutos'
      es.learn  'a few minutes ago',                  'hace unos minutos'
      es.learn  '%d minutes ago',                     'hace %d minutos'
      es.learn  'an hour ago',                        'hace una hora'
      es.learn  '%d hours ago',                       'hace %d horas'
      es.learn  'yesterday',                          'ayer'
      es.learn  '%d days ago',                        'hace %d días'
      es.learn  'a week ago',                         'hace una semana'
      es.learn  '%d weeks ago',                       'hace %d semanas'

      # lib/authentication.rb
      es.learn  'The requested resource requires administrator privileges',
                'Para acceder al recurso pedido se requieren privilegios de administrador'
      es.learn  'You must be logged in to access the requested resource',
                'Para acceder al recurso pedido debe iniciar una sesión.'
    end
  end

  def self.down
    remove_index  :translations, :column => [:locale_id, :key]
    drop_table    :translations
  end
end
