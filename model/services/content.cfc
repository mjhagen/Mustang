component extends="baseService" {
  public array function getByFQA( required  string            fqa,
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

    return ormExecuteQuery( hql, params, options );
  }
}