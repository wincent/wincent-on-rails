module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-react');

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    react: {
      files: {
        expand: true,
        cwd: 'app/assets/javascripts',
        src: ['**/*.js', 'bundle.js'],
        dest: 'server/build',
        ext: '.js',
        options: {
          harmony: true
        }
      }
    }
  });

  grunt.registerTask('default', ['react']);
};
