{% overrules %}

{% block edit_advanced_extra %}
    <div class="form-group row">
        <label class="control-label col-md-3" for="field-alternative-uris">{_ Alternative uris _}</label>
        <div class="col-md-9">
        	<textarea name="alternative_uris" id="field-alternative-uris" class="form-control" rows="3" {% if not is_editable %}disabled="disabled"{% endif %}>{{ r.alternative_uris }}</textarea>
        </div>
    </div>
{% endblock %}
