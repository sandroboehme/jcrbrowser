/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.sboehme.jcrbrowser;

import javax.servlet.http.HttpServletRequest;

import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceDecorator;
import org.apache.sling.api.resource.ResourceMetadata;
import org.apache.sling.api.resource.ResourceWrapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Overrules the resource resolver to let the JCRBrowser render servlets that have been registered by path.
 * 
 * E.g. the login servlet is registered by path using the URL /system/sling/login.
 * When calling /system/sling/login.jcrbrowser.html the servlet would usually be called to render the request.
 * To render this resource with the JCRBrowser this ResourceDecorator sets the resource type for requests that 
 * end with '.jcrbrowser.html' to 'jcrbrowser'.
 * @scr.component immediate="true" label="%defaultRtp.name"
 *                description="%defaultRtp.description"
 * @scr.property name="service.vendor" value="Sandro Boehme"
 * @scr.property name="service.description" value="JCRBrowser extension Resource Decorator"
 * @scr.service
 */
public class JCRBrowserExtensionResourceDecorator implements ResourceDecorator {

	private static final String JCRBROWSER_RESOURCE_TYPE = "jcrbrowser/view";
	private static final String JCRBROWSER_SELECTOR = "jcrbrowser.view";
	private final Logger log = LoggerFactory.getLogger(getClass());

	/**
	 * @see org.apache.sling.api.resource.ResourceDecorator#decorate(org.apache.sling.api.resource.Resource,
	 *      javax.servlet.http.HttpServletRequest)
	 */
	public Resource decorate(Resource resource, HttpServletRequest request) {
		// Returning null signals that no decoration is needed.
		return null;
	}

	/**
	 * @see org.apache.sling.api.resource.ResourceDecorator#decorate(org.apache.sling.api.resource.Resource)
	 */
	public Resource decorate(Resource resource) {
		// Returning null signals that no decoration is needed.
		Resource result = null;
		if (resource!=null){
			ResourceMetadata resourceMetadata = resource.getResourceMetadata();
			if (resourceMetadata!=null){
				String resolutionPathInfo = resourceMetadata.getResolutionPathInfo();
				if (resolutionPathInfo!=null && resolutionPathInfo.endsWith("." + JCRBROWSER_SELECTOR + ".html")){
					result = new ResourceWrapper(resource) {
						@Override
						public String getResourceType() {
							return JCRBROWSER_RESOURCE_TYPE;
						}

					};
				}
			}
		}
		return result;
	}
}