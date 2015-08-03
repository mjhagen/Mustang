component persistent=false
{
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public Any function init( obj, field )
  {
    if( isNull( obj ) or isNull( field ))
    {
      return this;
    }

    variables.data = evaluate( "obj.get#field#()" );
    variables.field = field;
    return this;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public Any function parseMissingMethod( obj, missingMethodName, missingMethodArguments )
  {
    if( len( missingMethodName ) lte 3 )
    {
      throw( "Missing method" );
    }

    var action = left( missingMethodName, 3 );
    var key = right( missingMethodName, len( missingMethodName ) - 3 );

    switch( action )
    {
      case  "get":
            if( validateData())
            {
              var workingDataSet = deserializeJSON( getJSONData());

              if( structKeyExists( workingDataSet, key ))
              {
                return workingDataSet[key];
              }
            }

            return nil();
            break;

      case  "set":
            if( not arrayLen( missingMethodArguments ))
            {
              throw( "Missing value to set" );
            }

            if( validateData())
            {
              var workingDataSet = deserializeJSON( getJSONData());
            }
            else
            {
              var workingDataSet = {};
            }

            workingDataSet[lCase( key )] = missingMethodArguments[1];

            evaluate( "obj.set#variables.field#(serializeJSON(workingDataSet))" );

            break;

      default:
            throw( "Missing method" );
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public String function getJSONData()
  {
    if( not isNull( variables.data ))
    {
      return variables.data;
    }

    return "";
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private Void function nil(){}

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private Boolean function validateData()
  {
    var workingDataSet = getJSONData();

    if( isNull( workingDataSet ))
    {
      return false;
    }

    if( isJSON( workingDataSet ))
    {
      workingDataSet = deserializeJSON( workingDataSet );
    }

    if( not isStruct( workingDataSet ))
    {
      return false;
    }

    return true;
  }
}