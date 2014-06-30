import os
import urllib

from google.appengine.api import users
from google.appengine.ext import ndb

import jinja2
import webapp2

import urllib2
import json
import urllib
import cgi

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    extensions=['jinja2.ext.autoescape'],
    autoescape=True)

class MainPage(webapp2.RequestHandler):

    def get(self):

        template_values = {}

        template = JINJA_ENVIRONMENT.get_template('index.html')
        self.response.write(template.render(template_values))

class Instagram(webapp2.RequestHandler):
    def get(self):
      tag = { 'tag' : str(cgi.escape(self.request.get('tag'))) }
      urlString = 'https://api.instagram.com/v1/tags/' + tag['tag']
      urlString += '/media/recent?count=10&client_id=29f0616e7de5406dabf18b310951a76c'
      request = urllib2.urlopen(urlString)
      jsonobj = json.loads(request.read())

      #TODO: escapes to protect against code injection
      body = ''
      k = 0
      for items in jsonobj['data']:
        obj = jsonobj['data'][k]
        images = obj['images']
        body += '<img src="' + images['low_resolution']['url'] + '">'
        k = k + 1

      self.response.write(body)

application = webapp2.WSGIApplication([
    ('/', MainPage),
    ('/instagram', Instagram)
], debug=True)
