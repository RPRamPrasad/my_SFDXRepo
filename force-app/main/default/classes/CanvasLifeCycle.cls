/**
* Author : Team Poseidon
* Date Created : 05/02/2019
* @description : LifeCycle class that sets up url to call HATS app using Canvas
*/
public with sharing class CanvasLifeCycle implements Canvas.CanvasLifecycleHandler{
    
     String newURL ;
     String canvasConnectedAppURL ;
     String encodedJsonParams;
     Case caseRecord;
    
    /**
     * @description method to exclude context types in Canvas
     * @return set of enums of exclusions
     */
    public Set<Canvas.ContextTypeEnum> excludeContextTypes(){
        return new Set<Canvas.ContextTypeEnum>();
    }
    
    /**
     * @description method that implements Canvas rendering
     * @param renderContext the rendering context that Canvas will use to show app
     */
    public void onRender(Canvas.RenderContext renderContext) {
 
        Canvas.ApplicationContext app = renderContext.getApplicationContext();
        Canvas.EnvironmentContext env = renderContext.getEnvironmentContext();        
        
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(env.getParametersAsJSON());
        String caseId = String.valueOf((String)params.get('caseId'));
        
        canvasConnectedAppURL = app.getCanvasUrl();
        
        encodedJsonParams = LTG_HATSNecho_Controller.getPolicyDetailsJson(caseId);
        newURL = '/HATSNecho/entry?'+'SFUserID='+ LTG_HATSNecho_Controller.getUserRecord().Alias +'&'+'hatsgv_JsonParams='+ encodedJsonParams + '&connectionName=' + LTG_HATSNecho_Controller.gethost();
        app.setCanvasUrlPath(newURL);
    }
}