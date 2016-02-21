component extends="root.services.baseService" {
  public component function getByFQA( required  string            fqa,
                                            root.model.locale locale,
                                            boolean           deleted = false,
                                            struct            options = { cacheable = true }) {
    var hql = "FROM content c WHERE c.fullyqualifiedaction = :fqa AND c.deleted != :deleted";
    var params = {
          fqa = fqa,
          deleted = !deleted
        };

    if( !isNull( locale )) {
      hql &= " AND c.locale = :locale";
      params.locale = locale;
    }

    var result = ormExecuteQuery( hql, params, options );

    if( arrayLen( result )) {
      return result[1];
    }

    return entityNew( "content" );
  }
}