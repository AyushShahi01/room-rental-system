from django.apps import AppConfig


class MapsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'maps'
    verbose_name = 'Maps & Routing'

    def ready(self):
        """
        Pre-load the OSM road graph into memory when Django starts up.
        This avoids downloading/parsing the graph on the first API request.
        """
        from .graph_loader import load_graph
        load_graph()
