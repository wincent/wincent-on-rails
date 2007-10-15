class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.integer     :locale_id
      t.string      :key
      t.string      :translation
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

      # app/controllers/sessions_controller.rb
      es.learn  'Successfully logged in.',            'Sesión iniciada con éxito.'
      es.learn  'Invalid login or passphrase.',       'Nombre de usuario o contraseña no válido.'
      es.learn  'You have logged out successfully.',  'Sesión cerrada con éxito.'

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
    end
  end

  def self.down
    remove_index  :translations, :column => [:locale_id, :key]
    drop_table    :translations
  end
end
